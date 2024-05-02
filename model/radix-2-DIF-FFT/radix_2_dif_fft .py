'''
                                            Radix 2 FFT DIF         

Description :               This code is designed to implement radix 2 FFT DIF. 
                             It first detects the number of input samples and 
            from this number it detects the number of stages and the number of groups in each stage. 
                    After this it starts to calculate FFT through looping on each group and 
            calculates the appropriate output according to input samples values and twiddle factor value.

Date: 05/2023
Author : Mohamed Sharaf
'''

import cmath
from math import *
from butterfly_r2 import *

num = input ("write input points: ")
input_list = num.split()
input_list = [float(x) for x in input_list]
print ("")

N = len(input_list)         # Number of Input Samples

radix = 2                   # radix used

no_stages = int (log2(N))   # Number of FFT stages

x_k = input_list.copy()     # output list 


for i in range (no_stages):
    no_groups = radix**i                    # Number of groups in each stage 

    no_TW = int (N / (radix*no_groups))     # Number of Butterfly units in each group

    m = 0

    input_list = x_k.copy()

    for k in range (no_groups):
        m = k * N // no_groups 
        for j in range (no_TW):

            twiddle = (cmath.exp(-2j * pi * no_groups/ N))

            [x_k[(j+m)] , x_k[(j+m)+no_TW]] = butterfly_unit(x_k[(j+m)],x_k[(j+m)+no_TW],twiddle**j)
            



# apply bit-reversal permutation
bit_reverse = [int('{:0{}b}'.format(i, no_stages)[::-1], 2) for i in range(N)]
for i in range(N):
    if i < bit_reverse[i]:
        x_k[i], x_k[bit_reverse[i]] = x_k[bit_reverse[i]], x_k[i]

print (x_k)
print ("")

for r in range (N):
    print (x_k[r])

