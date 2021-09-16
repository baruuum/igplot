//[[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
using namespace arma;

//' Procrustes Transform of Rectangular matrix
//' 
//' @param X dense matrix to transform
//' @param target dense matrix that is the target of the transform
//' @param translation boolean; whether positions should be translated
//' @param scale boolean; whether positions should be scaled
//' @return returns a list of four elements: 
//' \enumerate{
//'     \item the transformed matrix \code{Xstar}
//'     \item the rotation matrix \code{R}
//'     \item the translation vector \code{t_vec}
//'     \item the scaling factor \code{sigma}
//' }
//' The transformed matrix \code{Xstar} can be recreated by the equation \code{sigma * X * R} if \code{translation} is \code{FALSE}. If \code{translation} is \code{TRUE}, adding \code{t_vec} to each row of the matrix \code{sigma * X * R} completes the transformation.
//[[Rcpp::export(.transform_procrustes)]]
Rcpp::List procrustes(
        const mat &X,                // input
        const mat &target,           // target positions
        bool translation = true,     // whether to translate points
        bool scale = true            // whether to scale
){
    
    uword n = X.n_rows;
    uword k = X.n_cols;
    double n_inv = 1/(double)n;
    
    mat J = eye(n, n);
    if (translation)
        J -= ones(n, n) * n_inv;
    
    mat Y = target.t() * J * X;
    
    mat U;
    vec s;
    mat V;
    
    svd_econ(U, s, V, Y);
    
    mat R = V * U.t();
    
    double sigma = 1.0;
    
    if (scale)
        sigma = sum(diagvec(Y * R)) / sum(diagvec(X.t() * J * X));
    
    mat Xstar = sigma * X * R;
    rowvec t_vec(k);
    
    if (translation) {
        
        t_vec = n_inv * ones<rowvec>(n) * (target - sigma * X * R);
        Xstar.each_row() += t_vec;
        
    } else {
        
        t_vec.zeros();
        
    }
    
    return Rcpp::List::create(
        Rcpp::_["Xstar"] = Xstar,
        Rcpp::_["R"]     = R,
        Rcpp::_["t_vec"] = t_vec,
        Rcpp::_["sigma"] = sigma
    );
    
}
