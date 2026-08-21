///|
test "benchmark suite runs named cases and reports throughput inputs" {
  let suite = benchmark_suite([("small", "X: 1\nK: C\nC\n"), ("empty", "")], 3)
  inspect(suite.case_count(), content="2")
  inspect(suite.result("small").runs(), content="3")
  inspect(suite.result("empty").bytes(), content="0")
  inspect(suite.text().contains("small"), content="true")
}
