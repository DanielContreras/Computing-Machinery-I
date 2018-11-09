# Script to automatically display results of program
# Run chmod +X test.sh

printf "==================== C Version ====================\n"
gcc assign4.c -o a4.out && ./a4.out && rm a4.out

printf "==================== Assembly =====================\n"
m4 assign4.asm > assign4.s && gcc assign4.s -g -o assign4.out && ./assign4.out
# rm assign4.out assign4.s
