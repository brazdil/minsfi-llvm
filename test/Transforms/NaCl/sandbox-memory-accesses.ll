; RUN: opt %s -sandbox-memory-accesses -S | FileCheck %s


; CHECK: @__sfi_memory_base = external global i64

define void @func(i32* %ptr) {
  %val = load i32* %ptr
  ret void
}
; CHECK: define void @func(i32* %ptr) {
; CHECK-NEXT: %mem_base = load i64* @__sfi_memory_base
; CHECK-NEXT: %1 = ptrtoint i32* %ptr to i32
; CHECK-NEXT: %2 = zext i32 %1 to i64
; CHECK-NEXT: %3 = add i64 %mem_base, %2
; CHECK-NEXT: %4 = inttoptr i64 %3 to i32*
; CHECK-NEXT: %val = load i32* %4

define void @func2(i32* %ptr) {
  %val = load i32* %ptr
  store i32 %val, i32* %ptr
  ret void
}
; TODO...

define void @ptr_with_addend(i32 %ptr) {
  %add = add i32 %ptr, 1234
  %add.p = inttoptr i32 %add to i32*
  %val = load i32* %add.p
  ret void
}
; CHECK: define void @ptr_with_addend(i32 %ptr) {
; CHECK-NEXT: %mem_base = load i64* @__sfi_memory_base
; CHECK-NEXT: %add = add i32 %ptr, 1234
; CHECK-NEXT: %add.p = inttoptr i32 %add to i32*
; CHECK-NEXT: %1 = zext i32 %ptr to i64
; CHECK-NEXT: %2 = add i64 %mem_base, %1
; CHECK-NEXT: %3 = add i64 %2, 1234
; CHECK-NEXT: %4 = inttoptr i64 %3 to i32*
; CHECK-NEXT: %val = load i32* %4
