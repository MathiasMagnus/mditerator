#! /bin/bash

TARGET=md_iterator_3

#LLVMROOT=`realpath ~/development/llvm/INSTALL_RELEASE`
LLVMROOT=`realpath ~/development/gor-llvm/INSTALL_RELEASE`

LLVMFLAGS="
    -stdlib=libc++ -std=c++1z -fcoroutines-ts
    -fno-exceptions -fno-rtti
    -g0 -O3
    -fvectorize -march=native
    -ffast-math
    -fstrict-aliasing
    -fomit-frame-pointer
    -fno-asynchronous-unwind-tables -fno-unwind-tables
    -Rpass=loop-vectorize
    -Rpass-missed=loop-vectorize
    -Rpass-analysis=loop-vectorize
    -Wall
    "

ICPCFLAGS="
    -std=c++14
    -fno-exceptions -fno-rtti
    -g0 -O3
    -xAVX2
    -fast
    -fstrict-aliasing
    -fomit-frame-pointer
    -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm
    -Wall
    "    

GCCFLAGS="
    -std=c++1z 
    -fno-exceptions -fno-rtti -g0 -O3
    -ftree-vectorize -march=native
    -ffast-math
    -fstrict-aliasing
    -fomit-frame-pointer
    -fno-asynchronous-unwind-tables -fno-unwind-tables
    -Wall
    "

export LD_LIBRARY_PATH=${LLVMROOT}/lib:${LD_LIBRARY_PATH}

echo; echo "########################################################"; echo "### LLVM: EXECUTABLE     : COMPILING"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DTEST -DINDEX_GENERATOR -DINDEX_ITERATOR -Wl,-rpath=${LLVMROOT}/lib ${TARGET}.cpp -o ${TARGET}.llvm

echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING OPTIMIZED ASSEMBLY"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DSTREAM_TRIAD_INDEX_GENERATOR                                         -S ${TARGET}.cpp -o ${TARGET}_stream_triad_index_generator.llvm.asm
echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING OPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DSTREAM_TRIAD_INDEX_GENERATOR -emit-llvm                              -S ${TARGET}.cpp -o ${TARGET}_stream_triad_index_generator.llvm.ir
echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING UNOPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DSTREAM_TRIAD_INDEX_GENERATOR -emit-llvm -Xclang -disable-llvm-passes -S ${TARGET}.cpp -o ${TARGET}_stream_triad_index_generator.llvm.no_opt.ir
echo; echo "########################################################"; echo "### LLVM: INDEX ITERATOR : GENERATING OPTIMIZED ASSEMBLY"

echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING OPTIMIZED ASSEMBLY"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_GENERATOR                                         -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_generator.llvm.asm
echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING OPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_GENERATOR -emit-llvm                              -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_generator.llvm.ir
echo; echo "########################################################"; echo "### LLVM: INDEX GENERATOR: GENERATING UNOPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_GENERATOR -emit-llvm -Xclang -disable-llvm-passes -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_generator.llvm.no_opt.ir
echo; echo "########################################################"; echo "### LLVM: INDEX ITERATOR : GENERATING OPTIMIZED ASSEMBLY"

${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_ITERATOR                                          -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.llvm.asm
echo; echo "########################################################"; echo "### LLVM: INDEX ITERATOR : GENERATING OPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_ITERATOR -emit-llvm                               -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.llvm.ir
echo; echo "########################################################"; echo "### LLVM: INDEX ITERATOR : GENERATING UNOPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_INDEX_ITERATOR -emit-llvm -Xclang -disable-llvm-passes  -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.llvm.no_opt.ir
echo; echo "########################################################"; echo "### LLVM: LOOP           : GENERATING OPTIMIZED ASSEMBLY"

${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_LOOP                                                    -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.llvm.asm
echo; echo "########################################################"; echo "### LLVM: LOOP           : GENERATING OPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_LOOP -emit-llvm                                         -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.llvm.ir
echo; echo "########################################################"; echo "### LLVM: LOOP           : GENERATING UNOPTIMIZED IR"
${LLVMROOT}/bin/clang++ ${LLVMFLAGS} -DFILL_PI_LOOP -emit-llvm -Xclang -disable-llvm-passes            -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.llvm.no_opt.ir

###############################################################################

echo; echo "########################################################"; echo "### ICPC: EXECUTABLE     : COMPILING"
icpc ${ICPCFLAGS} -DTEST -DFILL_PI_INDEX_ITERATOR ${TARGET}.cpp -o ${TARGET}.icpc

echo; echo "########################################################"; echo "### ICPC: INDEX ITERATOR : GENERATING OPTIMIZATION REPORT"
icpc ${ICPCFLAGS} -DFILL_PI_INDEX_ITERATOR -qopt-report=5                  -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.icpc.rpt
echo; echo "########################################################"; echo "### ICPC: INDEX ITERATOR : GENERATING OPTIMIZED ASSEMBLY"
icpc ${ICPCFLAGS} -DFILL_PI_INDEX_ITERATOR -fcode-asm -fsource-asm -no-ipo -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.icpc.asm

echo; echo "########################################################"; echo "### ICPC: LOOP           : GENERATING OPTIMIZATION REPORT"
icpc ${ICPCFLAGS} -DFILL_PI_LOOP -qopt-report=5                            -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.icpc.rpt
echo; echo "########################################################"; echo "### ICPC: LOOP           : GENERATING OPTIMIZED ASSEMBLY"
icpc ${ICPCFLAGS} -DFILL_PI_LOOP -fcode-asm -fsource-asm -no-ipo           -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.icpc.asm

###############################################################################

echo; echo "########################################################"; echo "### GCC : EXECUTABLE     : COMPILING"
g++ ${GCCFLAGS} -DTEST -DFILL_PI_INDEX_ITERATOR ${TARGET}.cpp -o ${TARGET}.gcc

echo; echo "########################################################"; echo "### GCC : INDEX ITERATOR : GENERATING OPTIMIZED ASSEMBLY"
g++ ${GCCFLAGS} -DFILL_PI_INDEX_ITERATOR -fopt-info-vec -fopt-info-vec-missed -ftree-vectorizer-verbose=6 -S ${TARGET}.cpp -o ${TARGET}_fill_pi_index_iterator.gcc.asm

echo; echo "########################################################"; echo "### GCC : LOOP           : GENERATING OPTIMIZED ASSEMBLY"
g++ ${GCCFLAGS} -DFILL_PI_LOOP -fopt-info-vec -fopt-info-vec-missed -ftree-vectorizer-verbose=6           -S ${TARGET}.cpp -o ${TARGET}_fill_pi_loop.gcc.asm

