This repository contains code which for estimating high-dimensional networks using saturated log-linear point process models.  We consider a variant of an AR(1) model: 

<p align="center">
<img src="https://github.com/bzmark/Saturated-Point-Processes/blob/master/AR(1)%20NN%20and%20Sparsity/equation.png" />
</p>

Where g is a saturation function which forces stability of the process.  To estimate the matrix A we use regularized MLE for the following penalties:

* l_1 norm
* Nuclear norm
* Group lasso
* Nuclear norm plus l_1 norm

We also implement ARMA(1,1) model estimation with sparsity regularization.  

To solve the RMLE optimization problem we use the [SpaRSA algorithm](http://www.lx.it.pt/~mtf/SpaRSA/IEEE_TSP_2009_Wright_Nowak_Figueiredo.pdf).  The low-rank plus sparse model is optimized using alternating descent.

This code builds on code written by [Eric Hall](http://erichall87.github.io/) and [discussed here](https://arxiv.org/abs/1605.02693).
