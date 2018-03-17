module TheSync::Analyze

  def analyze_diffs
    _table = Arel::Table.new(self.table_name)
    _source = Arel::Table.new(@view_name)

    attrs = @source_columns.map { |col| _table[col] }
    query = _table.project(*attrs)
    query = query.join(_source).on(_table[primary_key].eq(_source[@source_pk]))

    first_mapping = @full_mappings[0]
    condition = _table[first_mapping[0]].not_eq(_source[first_mapping[1]])
    @full_mappings[1..-1].each do |mapping|
      condition = condition.or( _table[mapping[0]].not_eq(_source[mapping[1]]) )
    end
    query.where(condition)

    connection.execute(query.to_sql)
  end


  def analyze_inserts

  end


  def analyze_deletes

  end

end
