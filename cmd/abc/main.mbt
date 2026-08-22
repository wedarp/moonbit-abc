///|
fn main {
  let args = @env.args()
  match args {
    [_, command, path] => {
      let (code, output) = @cli.command_file(command, path)
      println(output)
      @sys.exit(code)
    }
    _ => {
      println(
        "Usage: moonbit-abc <check|format|format-check|json|analyze|benchmark> <file>",
      )
      @sys.exit(2)
    }
  }
}
