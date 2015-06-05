#Stupid MCMC example

#Markov Chain Monte Carlo provides a means of sampling from a distribution that is 
#known only up to a constant of proportionality.  It can also be used for 
#optimization, in which we seek the point with the highest function value.  To that end, simply 
#create a bunch of samples (run the chain), and then look for the x-value at the maximum.

#Suppose our function to maximize is exp(-.5*x^2).  Note that this 
#proportional to a standard normal distribution, but is not itself standard normal.
#Also note that the solution in this example is trivial, the max is at x=0.
#But it's a good example.

f<-function(x) exp(-.5*x^2)
g<-function(x) exp(-.5*x^2)+.5*exp(-(x-5)^2)
x1<-seq(from=-3,to=3,length.out=100)
x2<-seq(from=-3,to=8,length.out=100)
plot(x1,f(x1),type="l",lwd=2.5,main="Density")
plot(x2,g(x2),type="l",lwd=2.5,main="Density")

g.norm<-unlist(integrate(g,lower=-10,upper=15))$value
g.norm

#Define a function to run a single Markov Chain, as a function of the number of reps.
#At each step, propose a random change.  Accept the change if it moves uphill, and 
#accept with some probability if the change moves downhill.  Remove the first so many
#iterations as "burn-in".  The chain only creates valid samples from the distribution 
#once it reaches a steady-state.

one.chain<-function(nreps=100000,f,seed=7,x.start=rnorm(1)) {
  set.seed(seed)
  x<-vector(mode="numeric",length=nreps)
  burn=nreps/10

  #Random starting point
  x[1]<-x.start

  for(i in 2:nreps) {
    x.tmp<-x[i-1]+rnorm(1,sd=.2)
    phi<-f(x.tmp)/f(x[i-1])
    if(phi>1) {
      x[i]<-x.tmp
    } else {
      x[i]<-ifelse(rbinom(1,1,prob=phi),x.tmp,x[i-1])
    }
  }
  return(x[-(1:burn)])
}

#-----First function unimodal

#Run 100 reps.  Looks really bad
x<-one.chain(100,f)
hist(x,freq=FALSE,nc=50)
lines(sort(x),dnorm(sort(x)))
legend("topleft","True Density",lty="solid",bty="n")

#Run 1000 reps.  Looks bad
x<-one.chain(1000,f)
hist(x,freq=FALSE,nc=50)
lines(sort(x),dnorm(sort(x)))
legend("topleft","True Density",lty="solid",bty="n")

#Run 10,000 reps.  Looks a little better
x<-one.chain(10000,f)
hist(x,freq=FALSE,nc=50)
lines(sort(x),dnorm(sort(x)))
legend("topright","True Density",lty="solid",bty="n")

#Run 100,000 reps.  Looks good.
x<-one.chain(100000,f)
hist(x,freq=FALSE,nc=50)
lines(sort(x),dnorm(sort(x)))
legend("topright","True Density",lty="solid",bty="n")

#Run 1,000,000 reps.  Looks great.
x<-one.chain(1000000,f)
hist(x,freq=FALSE,nc=50)
lines(sort(x),dnorm(sort(x)))
legend("topright","True Density",lty="solid",bty="n")

#Find the x at which the function is maximized.  Success!
x[which(f(x)==max(f(x)))]



#-----Second function multi-modal

#Run 100 reps.  Looks really bad
x<-one.chain(100,g,x.start=6)
hist(x,freq=FALSE,nc=50,xlim=c(-3,8))
lines(x2,g(x2)/g.norm)
legend("topleft","True Density",lty="solid",bty="n")

#Run 1000 reps.  Hasn't found the other hill yet
x<-one.chain(1000,g,x.start=6)
hist(x,freq=FALSE,nc=50,xlim=c(-3,8))
lines(x2,g(x2)/g.norm)
legend("topleft","True Density",lty="solid",bty="n")

#Run 10,000 reps.  Found the other hill but levels are off
x<-one.chain(10000,g,x.start=6)
hist(x,freq=FALSE,nc=50)
lines(sort(x),g(sort(x))/g.norm)
legend("topright","True Density",lty="solid",bty="n")

#Run 100,000 reps.  Looks good.
x<-one.chain(100000,g,x.start=6)
hist(x,freq=FALSE,nc=50,xlim=c(-3,8))
lines(x2,g(x2)/g.norm)
legend("topright","True Density",lty="solid",bty="n")

#Run 5,000,000 reps.  Looks great.
x<-one.chain(5000000,g,x.start=6)
hist(x,freq=FALSE,nc=50,xlim=c(-3,8))
lines(x2,g(x2)/g.norm)
legend("topright","True Density",lty="solid",bty="n")

#Find the x at which the function is maximized.  Success!
x[which(g(x)==max(g(x)))]


