class TheSync::Analyzer
  include TheSync::Table
  attr_reader :adapter, :connection, :my_arel_table, :dest_arel_table, :synchro_type

  def initialize(options = {})
    @adapter = TheSync::Adapter.adapter(options[:dest])
    @dest = options[:dest]
    @connection = options[:connection]

    @synchro_type = options[:model_name]
    @table_name = options[:table_name]
    @dest_table = options[:dest_table]
    @primary_key = options[:primary_key].to_s
    @dest_primary_key = options[:dest_primary_key]

    @full_mappings = options[:full_mappings]
    @my_columns = [@primary_key] + @full_mappings.map { |col| col[0] }
    @dest_columns = [@dest_primary_key] + @full_mappings.map { |col| col[1] }

    instance_table
    @my_arel_table ||= Arel::Table.new(@table_name)
    @dest_arel_table ||= Arel::Table.new(@dest_table_name, as: 't1')
  end

  def cache_all_diffs
    ['update', 'insert', 'delete'].each do |action|
      cache_diffs(action)
    end
  end

  def cache_diffs(type = 'update')
    analyze_diffs(type).each do |diff|
      id = diff.delete(@primary_key).compact.first
      audit = SyncAudit.new synchro_type: synchro_type
      audit.synchro_id = id if @primary_key == 'id'
      audit.synchro_primary_key = @primary_key
      audit.synchro_primary_value = id
      audit.operation = type
      audit.audited_changes = diff
      audit.save
    end
  end

  def analyze_diffs(type = 'update')
    sql = fetch_diffs(type)
    results = connection.execute(sql)
    fields = results.fields.in_groups(2).first
    results.map do |result|
      r = result.in_groups(2)
      hash_value = fields.zip( r[0].zip(r[1]) ).to_h
      hash_value.select { |key, v| v[0] != v[1] || key == @primary_key  }
    end
  end

  def fetch_diffs(type = 'update')
    if type == 'update'
      query = analyze_table.join(dest_arel_table).on(my_arel_table[@primary_key].eq(dest_arel_table[@dest_primary_key]))
      query.where(analyze_conditions)
    elsif type == 'insert'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::RightOuterJoin).on(my_arel_table[@primary_key].eq(dest_arel_table[@dest_primary_key]))
      query.where(my_arel_table[@primary_key].eq(nil))
    elsif type == 'delete'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::OuterJoin)
                .on(my_arel_table[@primary_key].eq(dest_arel_table[@dest_primary_key]))
      query.where(my_arel_table[@primary_key].not_eq(nil).and(dest_arel_table[@dest_primary_key].eq(nil)))
    else
      query = analyze_table.join(dest_arel_table, Arel::Nodes::FullOuterJoin).on(my_arel_table[@primary_key].eq(dest_arel_table[@dest_primary_key]))
    end

    query.to_sql
  end

  def analyze_table
    attrs = @my_columns.map { |col| my_arel_table[col] }
    attrs += @dest_columns.map { |col| dest_arel_table[col] }
    my_arel_table.project(*attrs)
  end

  def analyze_conditions
    first_mapping = @full_mappings[0]
    condition = my_arel_table[first_mapping[0]].not_eq(dest_arel_table[first_mapping[1]])
    @full_mappings[1..-1].each do |mapping|
      condition = condition.or( my_arel_table[mapping[0]].not_eq(dest_arel_table[mapping[1]]) )
    end
    condition
  end

end
