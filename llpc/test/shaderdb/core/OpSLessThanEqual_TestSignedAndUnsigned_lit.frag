// NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py
// RUN: amdllpc -emit-lgc -gfxip 10.3 -o - %s | FileCheck -check-prefix=SHADERTEST %s

#version 450

layout(binding = 0) uniform Uniforms
{
    ivec2 i2_0, i2_1;
    uvec2 u2_0, u2_1;
};

layout(location = 0) out vec4 fragColor;

void main()
{
    bvec2 b2;

    b2 = lessThanEqual(i2_0, i2_1);

    fragColor = (b2.x) ? vec4(1.0) : vec4(0.5);
}

// SHADERTEST-LABEL: @lgc.shader.FS.main(
// SHADERTEST-NEXT:  .entry:
// SHADERTEST-NEXT:    [[TMP0:%.*]] = call ptr addrspace(7) (...) @lgc.create.load.buffer.desc.p7(i64 0, i32 0, i32 0, i32 0)
// SHADERTEST-NEXT:    [[TMP1:%.*]] = call ptr @llvm.invariant.start.p7(i64 -1, ptr addrspace(7) [[TMP0]])
// SHADERTEST-NEXT:    [[TMP2:%.*]] = load <2 x i32>, ptr addrspace(7) [[TMP0]], align 8
// SHADERTEST-NEXT:    [[TMP3:%.*]] = getelementptr inbounds <{ [2 x i32], [2 x i32], [2 x i32], [2 x i32] }>, ptr addrspace(7) [[TMP0]], i32 0, i32 1
// SHADERTEST-NEXT:    [[TMP4:%.*]] = load <2 x i32>, ptr addrspace(7) [[TMP3]], align 8
// SHADERTEST-NEXT:    [[TMP5:%.*]] = extractelement <2 x i32> [[TMP2]], i64 0
// SHADERTEST-NEXT:    [[TMP6:%.*]] = extractelement <2 x i32> [[TMP4]], i64 0
// SHADERTEST-NEXT:    [[DOTNOT:%.*]] = icmp sgt i32 [[TMP5]], [[TMP6]]
// SHADERTEST-NEXT:    [[TMP7:%.*]] = select reassoc nnan nsz arcp contract afn i1 [[DOTNOT]], <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>, <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
// SHADERTEST-NEXT:    call void (...) @lgc.create.write.generic.output(<4 x float> [[TMP7]], i32 0, i32 0, i32 0, i32 0, i32 0, i32 poison)
// SHADERTEST-NEXT:    ret void
//
