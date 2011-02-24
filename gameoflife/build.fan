using build

class Build : BuildPod
{
  new make()
  {
    podName = "gameoflife"
    summary = "Conway's game of life in Fantom"
    depends = ["sys 1.0", "util 1.0", "gfx 1.0", "fwt 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}