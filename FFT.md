# Fast Fourier Transform (FFT)
  The goal of this document is to explain the essential concepts of the FFT

# Table of Contents:

- [Concepts](#Concepts) 
- [Discrete Fourier Transform](#Discrete-Fourier-Transform)
- [Fast Fourier Transform](#Fast-Fourier-Transform)
- [Twiddle Factor Indexing](#Twiddle-Factor-Indexing)
- [References](#References)

# Concepts
Here are key concepts required to understand DFT:
  - Sampling rate: is the number of samples taken over a time period where N is the number of samples.
  - Sample interval: the time interval between samples.
  - Fundamental period:  is the period of all the samples taken.
  - Nyquist Frequency: is half the sampling rate. Which is the maximum frequency that can be detected for a given sampling rate. 
> You can find symbols definition [here](https://en.wikipedia.org/wiki/Glossary_of_mathematical_symbols).

# Discrete Fourier Transform
The DFT(Discrete Fourier Transform): is an algorithm used to convert discrete signal (equally spaced samples of a signal) from time domain into frequency domain. The Discrete Fourier Transform operates on an N-point sequence of numbers referred to as x(n). Which is defined as:
```math
X(k) = \sum_{n=0}^{N-1} x(n)w_{N}^{kn} \ \ \ \ \ \ \ \ \ \ \ k = 0, 1, 2, ..., N-1
```
Where the twiddle factor $\Rightarrow w_{N}^{nk} = e^{\frac{(-j2\Pi kn)}{N}}$

![DFT](/docs/assets/img/DFT.bmp)

# Fast Fourier Transform
Fast Fourier Transform (FFT): is an Efficient algorithm to compute the DFT in a much shorter time. FFT is more computationally efficient than the standard DFT as it reduces the computational complexity of DFT from $O(N^{2})$ to $O(Nlog_{2}N)$. There are several types of FFT algorithms like Cooley-Tukey FFT, Prime Factor Algorithm, Bruun’s FFT Algorithm, …etc. The basis of the FFT algorithm lies in the fact that an $N$–point DFT can be written as the sum of two $N/2$–point DFTs (one DFT of the even-indexed samples and one DFT of the odd-indexed samples) as:
```math
X(k) = \sum_{n=0}^{(N/2)-1} x(2n)w_{N/2}^{kn} + w_{N}^{kn}\sum_{n=0}^{(N/2)-1} x(2n+1)w_{N/2}^{kn} \ \ \ \ \ \ \ \ \ \ \ k = 0, 1, 2, ..., N-1
```
Each $N/2$-pt DFTs need only be evaluated for $k = 0, 1, 2, … , N/2 –1$, because $w_{N/2}^{kn}$ is periodic with period $N/2$. The complex-valued weighting factor on the second DFT is called a Twiddle Factor (TF). This decomposition of a DFT is shown for $N=8$ in Fig.1 below:

<figure>
  <figcaption>Fig.1 - Decomposing 8-pt DFT into 4-pt DFTs.</figcaption>
  <img src="/docs/assets/img/8-pt-to-4-pt-DFTs.png" alt="Trulli">
</figure>

the dots indicate summation (the two values going into a dot get added with the result going to the output) and a twiddle factor beside a line multiplies the value passing through the line. The crossed-line structure that combines the outputs of the two $4$-pt DFTs into the $8$-pt DFT outputs is called a Butterfly because of its shape. For clarity, one of the butterflies is shown in Fig.2 below:

<figure>
  <figcaption>Fig.2 - Butterfly Structure.</figcaption>
  <img src="/docs/assets/img/Butterfly-Structure.png" alt="Trulli">
</figure>

where the rules for forming the butterfly outputs are given. Note that the twiddle factors in this form of butterfly are $w_{N}^{m}$ and $w_{N}^{(m+N/2)}$. Some exploitable structure of the twiddle factors of the form $w_{N}^{(m+N/2)}$ hinge on the properties of complex numbers as shown below for $N=8$ in Fig.3

<figure>
  <figcaption>Fig.3 - Exploitable Structure of Twiddle Factors.</figcaption>
  <img src="/docs/assets/img/Exploitable-Structure-of-Twiddle-Factors.jpg" alt="Trulli">
</figure>

This allows the butterfly structure to be improved as shown in Fig.4 below:

<figure>
  <figcaption>Fig.4 - Transition to Improved Form of Butterfly.</figcaption>
  <img src="/docs/assets/img/Transition-Improved-Form-of-Butterfly.png" alt="Trulli">
</figure>

which is then used in Fig.5 below: 

<figure>
  <figcaption>Fig.5 - Improved Form of DFT Decomposition.</figcaption>
  <img src="/docs/assets/img/Improved-Form-of-DFT-Decomposition.png" alt="Trulli">
</figure>

to give an improved form of the DFT decomposition. This decomposition into half-length DFTs can be done again to each of the two $N/2$-pt. DFTs, and then again, and then again … until reaching 2-pt DFTs. If the resulting twiddle factors are handled using the “improved form” discussed above, the structure that results is the FFT, and is shown for N=8 in Fig.6 below:

<figure>
  <figcaption>Fig.6 - Illustration of FFT Structure for 8-pt DFT.</figcaption>
  <img src="/docs/assets/img/Illustration-of-FFT-Structure-for-8-pt.png" alt="Trulli">
</figure>

the parameters listed at the bottom of Figure will be explained below. 
First note that the diagram is clearly divided into Stages, with the output array of a stage being the input of the next stage. Each stage uses $N/2$ butterflies to transform $N$ numbers in its input array into $N$ numbers in its output array, but each stage configures those $N/2$ butterflies differently. Note that it is possible to store the output array of each stage back into the same memory locations that the inputs array was in; this is known as “in-place” computation of the FFT. It is also important to note that the order of the samples in the 1st Stage input array have been reordered by using bit-reversal permutation (this reordering will be discussed further below). For indexing purposes we consider xin to be the input array, containing the reordered samples of the signal. The final output array is in sequentially indexed order. Also note that the twiddle factors needed consist of $w_{N}^{0}$, $w_{N}^{1}$, $w_{N}^{2}$, and $w_{N}^{3}$, which is only half the total set. displayed in Fig.3; in fact, it is only the “bottom” four of those shown in Fig.3 due to the exploitable structure shown there. The twiddle factors needed for the various stages are shown in Figure 7 below:

<figure>
  <figcaption>Fig.7 - Twiddle Factors for Stages of 8-pt FFT.</figcaption>
  <img src="/docs/assets/img/Twiddle-Factors-8-pt.jpg" alt="Trulli">
</figure>

The reordering of the signal samples to form the input array to the first stage follows a very simple rule called bit reversal. To find the proper order for the input samples to be stored in the FFT input array you simply take the $(log_{2}N)$-bit binary representations of the $N$ integers 0 to $(N-1)$ and reverse the order of the bits. The resulting numbers give the needed order of the input signal samples.

- 0  (000) $\Rightarrow$ bit-reversal $\Rightarrow$ (000)  0
- 1  (001) $\Rightarrow$ bit-reversal $\Rightarrow$ (100)  4
- 2  (010) $\Rightarrow$ bit-reversal $\Rightarrow$ (010)  2
- 3  (011) $\Rightarrow$ bit-reversal $\Rightarrow$ (110)  6
- 4  (100) $\Rightarrow$ bit-reversal $\Rightarrow$ (001)  1
- 5  (101) $\Rightarrow$ bit-reversal $\Rightarrow$ (101)  5
- 6  (110) $\Rightarrow$ bit-reversal $\Rightarrow$ (011)  3
- 7  (111) $\Rightarrow$ bit-reversal $\Rightarrow$ (111)  7

Starting in the 1st Stage at the top butterfly of Fig.6, the diagram says to form the top output of the butterfly by adding $x(4)$ to $x(0)$ and to form the bottom output of the butterfly by subtracting $x(4)$ from $x(0)$. Note that here the twiddle factor in front of the butterfly is 1, as they are for all the $1^{st}$ Stage butterflies. Likewise, all the other $1^{st}$ Stage butterflies compute the sums and differences of their inputs and pass the results to their outputs and store them into the memory locations of the inputs. We can view this first stage as having $N/2$ blocks with a single butterfly per block (this idea of blocks will become clearer when we discuss the $2^{nd}$ Stage). Also note that the inputs to each of the $1^{st}$ stage butterflies are adjacent samples in the (reordered) input array; we say that the $1^{st}$ Stage butterflies have a $Butterfly Span = 1$. Also, the index distance between $1^{st}$ Stage blocks is 2, so we define $Block Step = 2$. We also define a parameter called Butterfly Step and set it to 1 for the $1^{st}$ Stage; this will be defined more precisely below for the $2^{nd}$ and $3^{rd}$ Stages.

Going now to the $2^{nd}$ Stage we again see a repetition of the butterfly structure, but with a different structure than in the $1^{st}$ Stage. Here it is clear that the butterflies have a Butterfly $Span = 2$ (i.e., the inputs to a $2^{nd}$ Stage butterfly are two indices away from each other in the $2^{nd}$ Stage input array). Although there are $N/2$ butterflies (as in each stage) there are two distinct blocks with two butterflies per block. The first block consists of the top two butterflies and the second block consists of the bottom two butterflies. Within each of these two blocks the index increment between butterflies is 1; that is, the top input of two adjacent butterflies within a block are offset by 1. Thus we say that the $Butterfly Step = 1$. Also, we note that the $Block Step = 4$ in the $2^{nd}$ Stage; that is, the top input of the bottom block is four indices away from the top input of the top block. The twiddle factors follow the same progression in each of the two blocks. The progression of the twiddle factors within a block is seen to be from $w_{N}^{0}$ to a $\frac{1}{4}$ of the way around the circle to $w_{N}^{2}$ as seen in Fig.3. That is, the twiddle factor angle step for this is $2π/4$. Alternatively, we can consider the set of all the twiddle factors needed for all stages (i.e., $w_{N}^{0}$, $w_{N}^{1}$, $w_{N}^{2}$, and $w_{N}^{3}$ ) to be indexed by their powers $(0, 1, 2, 3)$; then the indexes into this set for the two twiddle factors required for this stage is $0×(N/4)=0$ and $1×(N/4)=2$. So the twiddle factor index step used in each block of the $2^{nd}$ Stage is $N/4 = 2$.

Going to the $3^{rd}$ Stage we yet again see a repetition of the butterfly, but with a different structure than in the $1^{st}$ or $2^{nd}$ Stages. We see a single block of $N/2$ butterflies with $Butterfly Step = 1$ and $Butterfly Span = 4$. Because there is only one block the parameter $Block Step$ is not really needed; however, it is convenient here to think of $Block Step = N = 8$ (i.e., this value steps beyond the index range of the $3^{rd}$ Stage input array). The progression of the twiddle factors within the block is $w_{N}^{0}$, $w_{N}^{1}$, $w_{N}^{2}$, and $w_{N}^{3}$ and from Fig.3 we see that twiddle factor angle step for this progression is $2π/8$. Alternatively, the indexes into this set for the four twiddle factors required for this stage is $0×(N/8)=0$,  $1×(N/8)=1$,  $2×(N/8)=2$, and $3×(N/8)=3$, So the twiddle factor index step used in the single block of the $3^{rd}$ Stage is $N/8 = 1$.

# Twiddle Factor Indexing
The structure of the twiddle factors is the same for every block in a stage; thus, the twiddle factor indexing structure depends only on the current stage. Also, the number of different twiddle factors needed in each block is equal to the number of butterflies in the block (i.e., one twiddle factor per butterfly). From Fig.7 notice that in each stage, the needed twiddle factors follow a uniform angular progression. Thus, the key to the twiddle factor structure is determining the angular step between twiddle factors as a function of the stage index. Generalizing from Fig.7 we see that the first stage needs a single twiddle factor of $w_{N}^{0}=1$; the second stage needs two different twiddle factors, namely $w_{N}^{0}$ and $w_{N}^{N/4}$; the third stage needs four twiddle factors, namely $w_{N}^{(0xN/8)}=w_{N}^{0}$, $w_{N}^{(1xN/8)}=w_{N}^{N/8}$, $w_{N}^{(2xN/8)}=w_{N}^{N/4}$, and $w_{N}^{(3xN/8)}=w_{N}^{3N/8}$; etc. Thus we see that at the $k^{th}$ (indexed origin-0) stage we need $2^{k}$ twiddle factors chosen uniformly spread in angle from the set of all the $N/2$ needed twiddle factors (i.e., $w_{N}^{0}$, $w_{N}^{1}$, $w_{N}^{2}$, …, $w_{N}^{N/2-1}$). Equivalently, we are choosing $2^{k}$ equally spaced indices from the set of indices $0, 1, 2, … , N/2 –1$; thus, the step between these indices must be $TF Index Step = (N/2)/2^{k} = N/2^{k+1}$. Thus, the required indices into the twiddle factor table are $m×(TF Index Step) = mN/2^{k+1}$ for $m = 0, 1, 2, … , 2^{k}–1$.

# References
- [FFT](http://www.ws.binghamton.edu/Fowler/Fowler%20Personal%20Page/EE302_files/FFT%20Reading%20Material.pdf)
- [Wikipedia](https://en.wikipedia.org/wiki/Fast_Fourier_transform)
