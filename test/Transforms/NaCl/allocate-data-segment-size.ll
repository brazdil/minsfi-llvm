; RUN: opt %s -allocate-data-segment -S | FileCheck %s

@var1 = global i32 11
@var2 = global i32 22

; Check for a bug in which we got the following, which FlattenGlobals
; doesn't handle:
; @__sfi_data_segment_size = constant i64 mul nuw (i64 ptrtoint (i32* getelementptr (i32* null, i32 1) to i64), i64 2)

; CHECK: @__sfi_data_segment_size = constant i32 8
