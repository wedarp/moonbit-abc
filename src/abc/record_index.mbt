///|
/// Source index for multi-record ABC files.
pub struct RecordIndex {
  records : Array[String]
  starts : Array[Int]
} derive(Debug, Eq)

///|
/// Build an index while retaining each record verbatim.
pub fn record_index(source : String) -> RecordIndex {
  let records = split_abc_records(source)
  let starts = []
  let mut offset = 0
  for record in records {
    starts.push(offset)
    offset += record.length()
  }
  { records, starts }
}

///|
/// Number of records.
pub fn RecordIndex::record_count(self : RecordIndex) -> Int {
  self.records.length()
}

///|
/// Record text by zero-based index.
pub fn RecordIndex::record(self : RecordIndex, index : Int) -> String {
  if index < 0 || index >= self.records.length() {
    ""
  } else {
    self.records[index]
  }
}

///|
/// Zero-based record start offset.
pub fn RecordIndex::start(self : RecordIndex, index : Int) -> Int {
  if index < 0 || index >= self.starts.length() {
    -1
  } else {
    self.starts[index]
  }
}

///|
/// Find records whose title contains a literal fragment.
pub fn RecordIndex::find_title(
  self : RecordIndex,
  title : String,
) -> Array[Int] {
  let result = []
  for index in 0..<self.records.length() {
    if parse(self.records[index]).header_value("T").contains(title) {
      result.push(index)
    }
  }
  result
}

///|
/// Return all indexed record texts.
pub fn RecordIndex::records(self : RecordIndex) -> Array[String] {
  self.records
}
