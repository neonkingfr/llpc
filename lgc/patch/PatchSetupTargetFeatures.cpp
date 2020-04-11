/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2018-2020 Advanced Micro Devices, Inc. All Rights Reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 **********************************************************************************************************************/
/**
***********************************************************************************************************************
* @file  PatchSetupTargetFeatures.cpp
* @brief LLPC source file: contains declaration and implementation of class lgc::PatchSetupTargetFeatures.
***********************************************************************************************************************
*/
#include "CodeGenManager.h"
#include "Patch.h"
#include "PipelineState.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "llpc-patch-setup-target-features"

using namespace llvm;
using namespace lgc;

namespace lgc {

// =====================================================================================================================
// Pass to set up target features on shader entry-points
class PatchSetupTargetFeatures : public Patch {
public:
  static char ID;
  PatchSetupTargetFeatures() : Patch(ID) {}

  void getAnalysisUsage(AnalysisUsage &analysisUsage) const override {
    analysisUsage.addRequired<PipelineStateWrapper>();
  }

  bool runOnModule(Module &module) override;

private:
  PatchSetupTargetFeatures(const PatchSetupTargetFeatures &) = delete;
  PatchSetupTargetFeatures &operator=(const PatchSetupTargetFeatures &) = delete;
};

char PatchSetupTargetFeatures::ID = 0;

} // namespace lgc

// =====================================================================================================================
// Create pass to set up target features
ModulePass *lgc::createPatchSetupTargetFeatures() {
  return new PatchSetupTargetFeatures();
}

// =====================================================================================================================
// Run the pass on the specified LLVM module.
//
// @param [in,out] module : LLVM module to be run on
bool PatchSetupTargetFeatures::runOnModule(Module &module) {
  LLVM_DEBUG(dbgs() << "Run the pass Patch-Setup-Target-Features\n");

  Patch::init(&module);

  auto pipelineState = getAnalysis<PipelineStateWrapper>().getPipelineState(&module);
  CodeGenManager::setupTargetFeatures(pipelineState, &module);

  return true; // Modified the module.
}

// =====================================================================================================================
// Initializes the pass
INITIALIZE_PASS(PatchSetupTargetFeatures, DEBUG_TYPE, "Patch LLVM to set up target features", false, false)