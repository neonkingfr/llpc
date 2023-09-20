; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt --opaque-pointers=0 --enforce-pointer-metadata=1 --verify-each -passes='add-types-metadata,lower-await,lint,remove-types-metadata' -S %s 2>%t0.stderr | FileCheck -check-prefix=AWAIT %s
; RUN: count 0 < %t0.stderr
; RUN: opt --opaque-pointers=0 --enforce-pointer-metadata=1 --verify-each -passes='add-types-metadata,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,remove-types-metadata' -S %s 2>%t1.stderr | FileCheck -check-prefix=CORO %s
; RUN: count 0 < %t1.stderr
; RUN: opt --opaque-pointers=0 --enforce-pointer-metadata=1 --verify-each -passes='add-types-metadata,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,cleanup-continuations,lint,remove-types-metadata' -S %s 2>%t2.stderr | FileCheck -check-prefix=CLEANED %s
; RUN: count 0 < %t2.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%continuation.token = type { }

declare void @await.void(%continuation.token*)
declare i32 @await.i32(%continuation.token*)
declare %continuation.token* @async_fun()
declare %continuation.token* @async_fun_with_arg(i32)

define void @simple_await() !continuation.registercount !1 {
; AWAIT-LABEL: @simple_await(
; AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, i8* [[TMP0:%.*]], i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @continuation.prototype.simple_await to i8*), i8* bitcast (i8* (i32)* @continuation.malloc to i8*), i8* bitcast (void (i8*)* @continuation.free to i8*))
; AWAIT-NEXT:    [[TMP3:%.*]] = call i8* @llvm.coro.begin(token [[TMP2]], i8* null)
; AWAIT-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; AWAIT-NEXT:    [[TMP4:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(%continuation.token* [[TOK]])
; AWAIT-NEXT:    call void (i64, ...) @continuation.return(i64 [[RETURNADDR:%.*]]), !continuation.registercount !1
; AWAIT-NEXT:    unreachable
;
; CORO-LABEL: @simple_await(
; CORO-NEXT:  AllocaSpillBB:
; CORO-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0:%.*]] to %simple_await.Frame*
; CORO-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[SIMPLE_AWAIT_FRAME:%.*]], %simple_await.Frame* [[FRAMEPTR]], i32 0, i32 0
; CORO-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CORO-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; CORO-NEXT:    [[TMP1:%.*]] = bitcast { i8*, %continuation.token* } (i8*, i1)* @simple_await.resume.0 to i8*
; CORO-NEXT:    [[TMP2:%.*]] = insertvalue { i8*, %continuation.token* } undef, i8* [[TMP1]], 0
; CORO-NEXT:    [[TMP3:%.*]] = insertvalue { i8*, %continuation.token* } [[TMP2]], %continuation.token* [[TOK]], 1
; CORO-NEXT:    ret { i8*, %continuation.token* } [[TMP3]]
;
; CLEANED-LABEL: @simple_await(
; CLEANED-NEXT:  AllocaSpillBB:
; CLEANED-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANED-NEXT:    call void @continuation.save.continuation_state()
; CLEANED-NEXT:    [[TMP0:%.*]] = bitcast [2 x i32]* [[CONT_STATE]] to i8*
; CLEANED-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0]] to %simple_await.Frame*
; CLEANED-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[SIMPLE_AWAIT_FRAME:%.*]], %simple_await.Frame* [[FRAMEPTR]], i32 0, i32 0
; CLEANED-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CLEANED-NEXT:    [[TMP1:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP2:%.*]] = load i32, i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 8
; CLEANED-NEXT:    store i32 [[TMP3]], i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP4:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    call void (...) @registerbuffer.setpointerbarrier([2 x i32]* @CONTINUATION_STATE, i32* [[TMP4]])
; CLEANED-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 0
; CLEANED-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CLEANED-NEXT:    store i32 [[TMP6]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 0), align 4
; CLEANED-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 1
; CLEANED-NEXT:    [[TMP8:%.*]] = load i32, i32* [[TMP7]], align 4
; CLEANED-NEXT:    store i32 [[TMP8]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANED-NEXT:    [[TMP9:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP9]], align 4
; CLEANED-NEXT:    call void (i64, ...) @continuation.continue(i64 ptrtoint (%continuation.token* ()* @async_fun to i64), i32 [[TMP10]], i64 ptrtoint (void (i32)* @simple_await.resume.0 to i64)), !continuation.registercount !2, !continuation.returnedRegistercount !2
; CLEANED-NEXT:    unreachable
;
  %tok = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
  call void @await.void(%continuation.token* %tok)
  ret void, !continuation.registercount !1
}

define void @simple_await_entry() !continuation.entry !0 !continuation.registercount !1 {
; AWAIT-LABEL: @simple_await_entry(
; AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, i8* [[TMP0:%.*]], i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @continuation.prototype.simple_await_entry to i8*), i8* bitcast (i8* (i32)* @continuation.malloc to i8*), i8* bitcast (void (i8*)* @continuation.free to i8*))
; AWAIT-NEXT:    [[TMP3:%.*]] = call i8* @llvm.coro.begin(token [[TMP2]], i8* null)
; AWAIT-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; AWAIT-NEXT:    [[TMP4:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(%continuation.token* [[TOK]])
; AWAIT-NEXT:    call void (i64, ...) @continuation.return(i64 undef)
; AWAIT-NEXT:    unreachable
;
; CORO-LABEL: @simple_await_entry(
; CORO-NEXT:  AllocaSpillBB:
; CORO-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0:%.*]] to %simple_await_entry.Frame*
; CORO-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; CORO-NEXT:    [[TMP1:%.*]] = bitcast { i8*, %continuation.token* } (i8*, i1)* @simple_await_entry.resume.0 to i8*
; CORO-NEXT:    [[TMP2:%.*]] = insertvalue { i8*, %continuation.token* } undef, i8* [[TMP1]], 0
; CORO-NEXT:    [[TMP3:%.*]] = insertvalue { i8*, %continuation.token* } [[TMP2]], %continuation.token* [[TOK]], 1
; CORO-NEXT:    ret { i8*, %continuation.token* } [[TMP3]]
;
; CLEANED-LABEL: @simple_await_entry(
; CLEANED-NEXT:  AllocaSpillBB:
; CLEANED-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANED-NEXT:    [[TMP0:%.*]] = bitcast [2 x i32]* [[CONT_STATE]] to i8*
; CLEANED-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0]] to %simple_await_entry.Frame*
; CLEANED-NEXT:    [[TMP1:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP2:%.*]] = load i32, i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 8
; CLEANED-NEXT:    store i32 [[TMP3]], i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP4:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    call void (...) @registerbuffer.setpointerbarrier([2 x i32]* @CONTINUATION_STATE, i32* [[TMP4]])
; CLEANED-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 0
; CLEANED-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CLEANED-NEXT:    store i32 [[TMP6]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 0), align 4
; CLEANED-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 1
; CLEANED-NEXT:    [[TMP8:%.*]] = load i32, i32* [[TMP7]], align 4
; CLEANED-NEXT:    store i32 [[TMP8]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANED-NEXT:    [[TMP9:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP9]], align 4
; CLEANED-NEXT:    call void (i64, ...) @continuation.continue(i64 ptrtoint (%continuation.token* ()* @async_fun to i64), i32 [[TMP10]], i64 ptrtoint (void (i32)* @simple_await_entry.resume.0 to i64)), !continuation.registercount !2, !continuation.returnedRegistercount !2
; CLEANED-NEXT:    unreachable
;
  %tok = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
  call void @await.void(%continuation.token* %tok)
  ; Note: entry functions don't need a registercount annotation on return
  ret void
}

define void @await_with_arg(i32 %i) !continuation.registercount !1 {
; AWAIT-LABEL: @await_with_arg(
; AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, i8* [[TMP0:%.*]], i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @continuation.prototype.await_with_arg to i8*), i8* bitcast (i8* (i32)* @continuation.malloc to i8*), i8* bitcast (void (i8*)* @continuation.free to i8*))
; AWAIT-NEXT:    [[TMP3:%.*]] = call i8* @llvm.coro.begin(token [[TMP2]], i8* null)
; AWAIT-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun_with_arg(i32 [[I:%.*]]), !continuation.registercount !1, !continuation.returnedRegistercount !1
; AWAIT-NEXT:    [[TMP4:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(%continuation.token* [[TOK]])
; AWAIT-NEXT:    call void (i64, ...) @continuation.return(i64 [[RETURNADDR:%.*]]), !continuation.registercount !1
; AWAIT-NEXT:    unreachable
;
; CORO-LABEL: @await_with_arg(
; CORO-NEXT:  AllocaSpillBB:
; CORO-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0:%.*]] to %await_with_arg.Frame*
; CORO-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[AWAIT_WITH_ARG_FRAME:%.*]], %await_with_arg.Frame* [[FRAMEPTR]], i32 0, i32 0
; CORO-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CORO-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun_with_arg(i32 [[I:%.*]]), !continuation.registercount !1, !continuation.returnedRegistercount !1
; CORO-NEXT:    [[TMP1:%.*]] = bitcast { i8*, %continuation.token* } (i8*, i1)* @await_with_arg.resume.0 to i8*
; CORO-NEXT:    [[TMP2:%.*]] = insertvalue { i8*, %continuation.token* } undef, i8* [[TMP1]], 0
; CORO-NEXT:    [[TMP3:%.*]] = insertvalue { i8*, %continuation.token* } [[TMP2]], %continuation.token* [[TOK]], 1
; CORO-NEXT:    ret { i8*, %continuation.token* } [[TMP3]]
;
; CLEANED-LABEL: @await_with_arg(
; CLEANED-NEXT:  AllocaSpillBB:
; CLEANED-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANED-NEXT:    call void @continuation.save.continuation_state()
; CLEANED-NEXT:    [[TMP0:%.*]] = bitcast [2 x i32]* [[CONT_STATE]] to i8*
; CLEANED-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0]] to %await_with_arg.Frame*
; CLEANED-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[AWAIT_WITH_ARG_FRAME:%.*]], %await_with_arg.Frame* [[FRAMEPTR]], i32 0, i32 0
; CLEANED-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CLEANED-NEXT:    [[TMP1:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP2:%.*]] = load i32, i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 8
; CLEANED-NEXT:    store i32 [[TMP3]], i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP4:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    call void (...) @registerbuffer.setpointerbarrier([2 x i32]* @CONTINUATION_STATE, i32* [[TMP4]])
; CLEANED-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 0
; CLEANED-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CLEANED-NEXT:    store i32 [[TMP6]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 0), align 4
; CLEANED-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 1
; CLEANED-NEXT:    [[TMP8:%.*]] = load i32, i32* [[TMP7]], align 4
; CLEANED-NEXT:    store i32 [[TMP8]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANED-NEXT:    [[TMP9:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP9]], align 4
; CLEANED-NEXT:    call void (i64, ...) @continuation.continue(i64 ptrtoint (%continuation.token* (i32)* @async_fun_with_arg to i64), i32 [[TMP10]], i64 ptrtoint (void (i32)* @await_with_arg.resume.0 to i64), i32 [[I:%.*]]), !continuation.registercount !2, !continuation.returnedRegistercount !2
; CLEANED-NEXT:    unreachable
;
  %tok = call %continuation.token* @async_fun_with_arg(i32 %i), !continuation.registercount !1,  !continuation.returnedRegistercount !1
  call void @await.void(%continuation.token* %tok)
  ret void, !continuation.registercount !1
}

define i32 @await_with_ret_value() !continuation.registercount !1 {
; AWAIT-LABEL: @await_with_ret_value(
; AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, i8* [[TMP0:%.*]], i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @continuation.prototype.await_with_ret_value to i8*), i8* bitcast (i8* (i32)* @continuation.malloc to i8*), i8* bitcast (void (i8*)* @continuation.free to i8*))
; AWAIT-NEXT:    [[TMP3:%.*]] = call i8* @llvm.coro.begin(token [[TMP2]], i8* null)
; AWAIT-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; AWAIT-NEXT:    [[TMP4:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(%continuation.token* [[TOK]])
; AWAIT-NEXT:    [[TMP5:%.*]] = call i32 @continuations.getReturnValue.i32()
; AWAIT-NEXT:    call void (i64, ...) @continuation.return(i64 [[RETURNADDR:%.*]], i32 [[TMP5]]), !continuation.registercount !1
; AWAIT-NEXT:    unreachable
;
; CORO-LABEL: @await_with_ret_value(
; CORO-NEXT:  AllocaSpillBB:
; CORO-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0:%.*]] to %await_with_ret_value.Frame*
; CORO-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[AWAIT_WITH_RET_VALUE_FRAME:%.*]], %await_with_ret_value.Frame* [[FRAMEPTR]], i32 0, i32 0
; CORO-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CORO-NEXT:    [[TOK:%.*]] = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
; CORO-NEXT:    [[TMP1:%.*]] = bitcast { i8*, %continuation.token* } (i8*, i1)* @await_with_ret_value.resume.0 to i8*
; CORO-NEXT:    [[TMP2:%.*]] = insertvalue { i8*, %continuation.token* } undef, i8* [[TMP1]], 0
; CORO-NEXT:    [[TMP3:%.*]] = insertvalue { i8*, %continuation.token* } [[TMP2]], %continuation.token* [[TOK]], 1
; CORO-NEXT:    ret { i8*, %continuation.token* } [[TMP3]]
;
; CLEANED-LABEL: @await_with_ret_value(
; CLEANED-NEXT:  AllocaSpillBB:
; CLEANED-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANED-NEXT:    call void @continuation.save.continuation_state()
; CLEANED-NEXT:    [[TMP0:%.*]] = bitcast [2 x i32]* [[CONT_STATE]] to i8*
; CLEANED-NEXT:    [[FRAMEPTR:%.*]] = bitcast i8* [[TMP0]] to %await_with_ret_value.Frame*
; CLEANED-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[AWAIT_WITH_RET_VALUE_FRAME:%.*]], %await_with_ret_value.Frame* [[FRAMEPTR]], i32 0, i32 0
; CLEANED-NEXT:    store i64 [[RETURNADDR:%.*]], i64* [[RETURNADDR_SPILL_ADDR]], align 4
; CLEANED-NEXT:    [[TMP1:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP2:%.*]] = load i32, i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 8
; CLEANED-NEXT:    store i32 [[TMP3]], i32* [[TMP1]], align 4
; CLEANED-NEXT:    [[TMP4:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    call void (...) @registerbuffer.setpointerbarrier([2 x i32]* @CONTINUATION_STATE, i32* [[TMP4]])
; CLEANED-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 0
; CLEANED-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CLEANED-NEXT:    store i32 [[TMP6]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 0), align 4
; CLEANED-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[CONT_STATE]], i32 0, i32 1
; CLEANED-NEXT:    [[TMP8:%.*]] = load i32, i32* [[TMP7]], align 4
; CLEANED-NEXT:    store i32 [[TMP8]], i32* getelementptr inbounds ([2 x i32], [2 x i32]* @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANED-NEXT:    [[TMP9:%.*]] = call i32* @continuation.getContinuationStackOffset()
; CLEANED-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP9]], align 4
; CLEANED-NEXT:    call void (i64, ...) @continuation.continue(i64 ptrtoint (%continuation.token* ()* @async_fun to i64), i32 [[TMP10]], i64 ptrtoint (void (i32, i32)* @await_with_ret_value.resume.0 to i64)), !continuation.registercount !2, !continuation.returnedRegistercount !2
; CLEANED-NEXT:    unreachable
;
  %tok = call %continuation.token* @async_fun(), !continuation.registercount !1, !continuation.returnedRegistercount !1
  %res = call i32 @await.i32(%continuation.token* %tok)
  ret i32 %res, !continuation.registercount !1
}

!continuation.stackAddrspace = !{!2}

!0 = !{}
!1 = !{i32 0}
!2 = !{i32 21}