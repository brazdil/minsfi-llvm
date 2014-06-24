; RUN: opt < %s -strip-tls -S | FileCheck %s

@var = thread_local global i32 123
; CHECK: @var = global i32 123
