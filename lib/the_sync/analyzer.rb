class TheSync::Analyzer
  include TheSync::Table
  attr_reader :adapter, :my_arel_table, :dest_arel_table, :synchro_type

  def initialize(options = {})
    @adapter = TheSync::Adapter.new(options[:dest])
    @dest = options[:dest]
    @record = options[:record]
    @server_id = options[:server_id]

    @synchro_type = @record.name
    @table_name = @record.table_name
    @dest_table = options[:dest_table]
    @primary_key = options[:primary_key]
    @dest_primary_key = options[:dest_primary_key]

    @full_mappings = options[:full_mappings]
    @my_columns = @primary_key + @full_mappings.map { |col| col[0] }
    @dest_columns = @dest_primary_key + @full_mappings.map { |col| col[1] }

    instance_table
    @my_arel_table ||= Arel::Table.new(@table_name)
    @dest_arel_table ||= Arel::Table.new(@dest_table_name, as: 't1')
  end

  def connection
    @record.connection
  end

  def skip_analyze?(type)
    ( type == 'delete' && !@primary_key.include?(@record.primary_key) ) ||
      ( type == 'insert' && @record.id_insert? && !@primary_key.include?(@record.primary_key) )
  end

  def cache_diffs(type = 'update')
    analyze_diffs(type).each do |diff|
      audit = SyncAudit.new synchro_type: synchro_type

      _params = {}
      @primary_key.each do |primary_key|
        _params[primary_key] = diff.delete(primary_key).compact.first
      end

      audit.synchro_params = _params
      audit.synchro_id = _params['id']

      audit.operation = type
      audit.audited_changes = diff
      begin
        audit.save
      rescue ActiveRecord::ValueTooLong => e # todo not require active record
        puts e.message
      end
    end
  end

  def analyze_diffs(type = 'update')
    return [] if skip_analyze?(type)
    sql = fetch_diffs(type)
    results = connection.execute(sql)
    fields = results.fields.in_groups(2).first
    results.map do |result|
      r = result.in_groups(2)
      hash_value = fields.zip( r[0].zip(r[1]) ).to_h
      hash_value.select do |key, v|
        v[0].to_s != v[1].to_s || @primary_key.include?(key)
      end
    end
  end

  def fetch_diffs(type = 'update')
    if type == 'update'
      query = analyze_table.join(dest_arel_table).on(on_conditions)
      query.where(analyze_conditions)
    elsif type == 'insert'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::RightOuterJoin).on(on_conditions)
      query.where(my_arel_table[@primary_key[0]].eq(nil))
    elsif type == 'delete'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::OuterJoin).on(on_conditions)
      query.where(my_arel_table[@primary_key[0]].not_eq(nil).and(dest_arel_table[@dest_primary_key[0]].eq(nil)))
    else
      query = analyze_table.join(dest_arel_table, Arel::Nodes::FullOuterJoin).on(on_conditions)
    end

    query.to_sql
  end

  def analyze_table
    attrs = @my_columns.map { |col| my_arel_table[col] }
    attrs += @dest_columns.map { |col| dest_arel_table[col] }
    my_arel_table.project(*attrs)
  end

  def analyze_conditions
    mappings = @full_mappings.map do |mapping|
      my_arel_table[mapping[0]].not_eq(dest_arel_table[mapping[1]])
    end
    Arel::Nodes::SqlLiteral.new mappings.map(&:to_sql).join(' OR ')
  end

  def on_conditions
    mappings = @primary_key.map.with_index do |left_key, index|
      my_arel_table[left_key].eq(dest_arel_table[@dest_primary_key[index]])
    end
    Arel::Nodes::SqlLiteral.new mappings.map(&:to_sql).join(' AND ')
  end

end
