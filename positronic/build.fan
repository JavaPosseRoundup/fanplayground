#! /usr/bin/env fan

using build

**
** Build: util
**
class Build : BuildPod
{
  new make()
  {
    podName = "positronic"
    summary = "Positronic Variables"
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
    docSrc  = true
  }
}

