function y = convol(irf, x)
% convol(irf, x) performs a convolution of the instrumental response 
% function irf with the decay function x. Periodicity (=length(x)) is assumed.

mm = mean(irf(end-10:end));
if size(x,1)==1 || size(x,2)==1
    irf = irf(:);
    x = x(:);
end
p = size(x,1);
n = length(irf);
if p>n
    irf = [irf; mm*ones(p-n,1)]; 
else
    irf = irf(1:p);
end
y = real(ifft((fft(irf)*ones(1,size(x,2))).*fft(x)));
t = rem(rem(0:n-1,p)+p,p)+1;
y = y(t,:);