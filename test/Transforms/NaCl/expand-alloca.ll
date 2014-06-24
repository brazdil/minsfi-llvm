; RUN: opt %s -expand-allocas -S | FileCheck %s

declare void @foo()
declare void @external_func(i8*, i8*)


; CHECK: @__sfi_stack = internal global i32 1073741824

define void @alloca() {
  call void @foo()
  %var1 = alloca i8, i32 10
  %var2 = alloca i8, i32 20
  call void @external_func(i8* %var1, i8* %var2)
  ret void
}
; CHECK: define void @alloca()
; CHECK-NEXT: %frame_top = load i32* @__sfi_stack{{$}}
; CHECK-NEXT: %frame_bottom = add i32 %frame_top, -30
; CHECK-NEXT: store i32 %frame_bottom, i32* @__sfi_stack
; CHECK-NEXT: call void @foo()
; CHECK-NEXT: %1 = add i32 %frame_top, -10
; CHECK-NEXT: %var1 = inttoptr i32 %1 to i8*
; CHECK-NEXT: %2 = add i32 %frame_top, -30
; CHECK-NEXT: %var2 = inttoptr i32 %2 to i8*
; CHECK-NEXT: call void @external_func(i8* %var1, i8* %var2)
; CHECK-NEXT: store i32 %frame_top, i32* @__sfi_stack
; CHECK-NEXT: ret void


; Check that all functions refer to the same __sfi_stack variable.
define void @second_function() {
  alloca i8, i32 10
  ret void
}
; CHECK: define void @second_function()
; CHECK-NEXT: %frame_top = load i32* @__sfi_stack{{$}}


; If a function contains no allocas, it doesn't need to modify and
; restore __sfi_stack.
define void @func_without_alloca() {
  ret void
}
; CHECK: define void @func_without_alloca() {
; CHECK-NEXT: ret void
