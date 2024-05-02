'''
                                            Radix 4 FFT DIF         

Description :               This code is designed to implement radix 4 FFT DIF. 
                             It first detects the number of input samples and 
            from this number it detects the number of stages and the number of groups in each stage. 
                    After this it starts to calculate FFT through looping on each group and 
            calculates the appropriate output according to input samples values and twiddle factor value.

Date: 05/2023
Author : Mohamed Sharaf
'''

import cmath
from math import *

num = input ("write input points: ")
x_n = num.split()
x_n = [float(x) for x in x_n]

print (x_n)

N = len(x_n)                    # Number of Input Samples
print (N)

radix = 4                       # radix used

no_stages = int (log(N,4))      # Number of FFT stages
print (no_stages)

x_k = x_n.copy()                # output list
# x_first = []
# x_second = []


print ("")

for i in range (no_stages):
    no_groups = radix**i                    # Number of groups in each stage
    # print (no_groups)
    no_TW = int (N / (radix*no_groups))     # Number of Butterfly units in each group
    # print (no_TW)
    m = 0

    x_n = x_k.copy()
    print (x_n)

    for k in range (no_groups):
        m = k * N // no_groups 
        for j in range (no_TW):

            twiddle = (cmath.exp(-2j * pi * no_groups/ N))

            x_k[(j+m)]= x_n[(j+m)] + x_n[(j+m)+no_TW] + x_n[(j+m)+2*no_TW] + x_n[(j+m)+3*no_TW]

            x_k[(j+m)+no_TW] = (x_n[(j+m)] - 1j*x_n[(j+m)+no_TW] - x_n[(j+m)+2*no_TW] + 1j*x_n[(j+m)+3*no_TW])*(twiddle**j)

            x_k[(j+m)+2*no_TW] = (x_n[(j+m)] - x_n[(j+m)+no_TW] + x_n[(j+m)+2*no_TW] - x_n[(j+m)+3*no_TW])*(twiddle**(2*j))

            x_k[(j+m)+3*no_TW] = (x_n[(j+m)] + 1j*x_n[(j+m)+no_TW] - x_n[(j+m)+2*no_TW] - 1j*x_n[(j+m)+3*no_TW]) * (twiddle**(3*j))
            
            print ("")
            print (j+m)
            print ((j+m)+no_TW)
            print ((j+m)+2*no_TW)
            print ((j+m)+3*no_TW)
            print ("")

        #print (x_k)
        
    
print (x_k)
print ("")
temp = []

'''
for k in range (no_groups):
        m = k * N // no_groups 
        for j in range (no_TW):
            x_k[(j+m)] = temp[m]
            
            x_k[(j+m)+no_TW] = temp[m + N // 4]
            x_k[(j+m)+2*no_TW] = temp[m + N // 2]
            x_k[(j+m)+3*no_TW] = temp[m + 3*N // 4]
'''         


# apply bit-reversal permutation
'''
for b in range (N//4):
    m = b * N // 4
    
    x_k[m] = temp[m]
    x_k[m + 1] = temp[m + N // 4]
    x_k[m + 2] = temp[m + N // 2]
    #x_k[m + 3] = temp[m + 3*N // 4]
'''
for b in range (N//4):
    
    temp.append(x_k[b])
    temp.append(x_k[b + N // 4])
    temp.append(x_k[b + N // 2])
    temp.append(x_k[b + 3*N // 4])

x_k = temp.copy()
print (x_k)



