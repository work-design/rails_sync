module TheSync::Analyze

  def analyze_diffs(type = 'update')
    sql = fetch_diffs(type)
    results = connection.execute(sql)
    fields = results.fields.in_groups(2).first
    arr_value = results.map do |result|
      r = result.in_groups(2)
      hash_value = fields.zip( r[0].zip(r[1]) ).to_h
      hash_value.select { |key, v| v[0] != v[1] || key == primary_key  }
    end
    arr_value
    #hash_value = .zip(arr_value)
  end

  def cache_diffs(type = 'update')
    analyze_diffs(type).each do |diff|
      audit = SyncAudit.new synchro_type: self.name
      audit.synchro_id = diff.delete('id').first
      audit.action = type
      audit.audited_changes = diff
      audit.save
    end
  end

  def fetch_diffs(type = 'update')
    if type == 'update'
      query = analyze_table.join(dest_arel_table).on(my_arel_table[primary_key].eq(dest_arel_table[@dest_pk]))
      query.where(analyze_conditions)
    elsif type == 'insert'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::RightOuterJoin).on(my_arel_table[primary_key].eq(dest_arel_table[@dest_pk]))
      query.where(my_arel_table[primary_key].eq(nil))
    elsif type == 'delete'
      query = analyze_table.join(dest_arel_table, Arel::Nodes::OuterJoin).on(my_arel_table[primary_key].eq(dest_arel_table[@dest_pk]))
      query.where(dest_arel_table[@dest_pk].eq(nil))
    else
      query = analyze_table.join(dest_arel_table, Arel::Nodes::FullOuterJoin).on(my_arel_table[primary_key].eq(dest_arel_table[@dest_pk]))
    end

    query.to_sql
  end

  def analyze_table
    attrs = @my_columns.map { |col| my_arel_table[col] }
    attrs += @dest_columns.map { |col| dest_arel_table[col] }
    my_arel_table.project(*attrs)
  end

  def my_arel_table
    @my_arel_table ||= Arel::Table.new(self.table_name)
  end

  def dest_arel_table
    @dest_arel_table ||= Arel::Table.new(@view_name)
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
