# [Reduce REPL printing](@id reduce_repl_printing)

By default `PowerSystems.jl` outputs to the REPL all Logging statements, which can be
overwhelming in some cases.

Use [`configure_logging`](@ref) to create a logger with your preferences for which logging
statements should be printed to the console or a log file:

**Example**: Set log output to only see error messages in the console

```@example reduce_repl_printing
using PowerSystems
using Logging
configure_logging(; console_level = Logging.Error)
```

**Note:** log messages are not automatically flushed to files. Call
`flush(logger)` to make this happen.

[Refer to this
page](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/dev_guide/logging/#Use-Cases)
for more logging configuration options. Note that it describes how to enable
debug logging for some log messages but not others.
