using build

class Build : BuildPod
{

  new make()
  {
    podName = "positronic"
    summary = "Positronic Variables"
    version = Version.fromStr("1.0.52")
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]

    docApi  = true
    docSrc  = true
  }
}