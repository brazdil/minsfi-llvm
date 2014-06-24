; RUN: opt < %s -sandbox-indirect-calls -S | FileCheck %s

@addr_taker_var1 = global i32 ptrtoint (void ()* @target_func1 to i32)
@addr_taker_var2 = global i32 ptrtoint (i32 (i32)* @target_func2 to i32)

; CHECK: @addr_taker_var1 = global i32 1
; CHECK: @addr_taker_var2 = global i32 2

; CHECK: @__sfi_function_table = internal constant [3 x i8*] [i8* null, i8* bitcast (void ()* @target_func1 to i8*), i8* bitcast (i32 (i32)* @target_func2 to i8*)]


define void @target_func1() {
  ret void
}

define i32 @target_func2(i32 %arg) {
  ret i32 %arg
}

; Direct calls should be left alone.
define void @direct_call() {
  call void @target_func1()
  call i32 @target_func2(i32 123)
  ret void
}
; CHECK: define void @direct_call() {
; CHECK: call void @target_func1()
; CHECK: call i32 @target_func2(i32 123)

define i32 @addr_taker_func() {
  %func = ptrtoint void ()* @target_func1 to i32
  ret i32 %func
}
; CHECK: define i32 @addr_taker_func()
; CHECK-NEXT: ret i32 1

define void @caller(i32 %func) {
  %func2 = inttoptr i32 %func to void ()*
  call void %func2()
  ret void
}
; CHECK: define void @caller(i32 %func) {
; CHECK-NEXT: %func_gep = getelementptr {{.*}} @__sfi_function_table, i32 0, i32 %func
; CHECK-NEXT: %func1 = load i8** %func_gep
; CHECK-NEXT: %func_bc = bitcast i8* %func1 to void ()*
; CHECK-NEXT: call void %func_bc()


; Example of a function which doesn't follow the normal form, and
; which isn't handled.
;
; declare void @f(...)
;
; define void @use_as_arg() {
;   call void (...)* @f(void ()* @target_func)
;   ret void
; }
