#! /usr/bin/env fan
//
// Copyright (c) 2010, Fred Simon
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Nov 10  Fred Simon  Creation
//

using build

**
** Build: xml
**
class Build : BuildPod
{
  new make()
  {
    podName = "digitalspace"
    summary = "Quatum Space state machine experiments"
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}

