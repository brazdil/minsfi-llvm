; RUN: opt %s -allocate-data-segment -S | FileCheck %s
; RUN: opt %s -allocate-data-segment -S | FileCheck %s -check-prefix=CLEAN

@var1 = global i64 1234
@var2 = global i32 56

@reloc = global i64* @var1
@reloc_end = global i32* getelementptr (i32* @var2, i32 1)


; CHECK: @__sfi_data_segment = constant %data_template { i64 1234, i32 56, i64* getelementptr (%data_template* inttoptr (i32 65536 to %data_template*), i32 0, i32 0), i32* getelementptr inbounds (i32* getelementptr (%data_template* inttoptr (i32 65536 to %data_template*), i32 0, i32 1), i32 1) }

; CHECK: @__sfi_data_segment_size = constant i32 32

; CLEAN-NOT: @var


define i32 @ref_to_var() {
  %val = load i32* @var2
  ret i32 %val
}
; CHECK: define i32 @ref_to_var() {
; CHECK-NEXT: %val = load i32* getelementptr (%data_template* inttoptr (i32 65536 to %data_template*), i32 0, i32 1)
