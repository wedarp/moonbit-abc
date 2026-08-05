///|
fn main {
  let args = @sys.get_cli_args()
  match args {
    [_, command, path] => {
      let (code, output) = @cli.command_file(command, path)
      println(output)
      @sys.exit(code)
    }
    _ => {
      println("Usage: moonbit-abc <check|format|json> <file>")
      @sys.exit(2)
    }
  }
}
