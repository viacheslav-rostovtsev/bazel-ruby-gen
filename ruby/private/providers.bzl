RubyLibraryInfo = provider (
  fields = {
    "deps" : "A depset",
    "info" : "info",
  }
)

RubyContext = provider(
  fields = {
    "bin" : "bin",
    "info" : "info",
  }
)

CgoContextData = provider()