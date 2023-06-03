echo -e "\nStarting compilation...\n"

# ENV
CONFIG=vendor/sixteen_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="$HOME/1/out/arch/arm64/boot/Image.gz-dtb"
export KBUILD_BUILD_USER="fiy"
export KBUILD_BUILD_HOST="yoigang"
export PATH="$HOME/clang/google/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/clang/google/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$($HOME/clang/google/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=$HOME/out

# Functions
clang_build () {
    make -j$(nproc --all) O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
			  LD="ld.lld" \
			  AS="llvm-as" \
			  OBJCOPY="llvm-objcopy" \
			  OBJDUMP="llvm-objdump" \
                          CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=$HOME/gcc/aarch64-linux-android-4.9/bin/aarch64-linux-android- \
                          CROSS_COMPILE_ARM32=$HOME/gcc/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
echo -e "\nCompiling $ZIPNAME\n"
clang_build
if [ -f "$out/arch/arm64/boot/Image.gz" ] && [ -f "$out/arch/arm64/boot/dtbo.img" ] && [ -f "$out/arch/arm64/boot/dts/qcom/trinket.dtb" ]; then
 echo -e "\nKernel compiled succesfully! Zipping up...\n"
 ZIPNAME="SixTeen•Kernel•MIUI•R•Ginkgo•Willow-$(date '+%Y%m%d-%H%M').zip"
 if [ ! -d AnyKernel3 ]; then
  git clone -q https://github.com/Kyvangka1610/AnyKernel3.git
 fi;
 cp -f $out/arch/arm64/boot/Image.gz AnyKernel3
 cp -f $out/arch/arm64/boot/dtbo.img AnyKernel3
 cp -f $out/arch/arm64/boot/dts/qcom/trinket.dtb AnyKernel3/dtb
 cd AnyKernel3
 zip -r9 "$HOME/$ZIPNAME" *
 cd ..
 rm -rf AnyKernel3
 echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
 echo -e "Zip: $ZIPNAME\n"
 rm -rf $out
else
 echo -e "\nCompilation failed!\n"
fi;
