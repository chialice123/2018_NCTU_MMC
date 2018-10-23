clear;
I = imread('MARBLES.bmp');
ImageSize = 8*prod(size(I));
% from RGB to Y'CbCr 
if size(I,3)==3
    Y = rgb2ycbcr(I);
else
    rgbimage(:,:,1) = I;
    rgbimage(:,:,2) = I;
    rgbimage(:,:,3) = I;
    Y = rgb2ycbcr(rgbimage);
end
% downsampling because oue eyes are not sensitive to color
Y_d = Y;
% not to do downsampling for intensity
% Y_d(:,:,1) = 4*round(Y_d(:,:,1)/4);
Y_d(:,:,2) = 4*round(Y_d(:,:,2)/4);
Y_d(:,:,3) = 4*round(Y_d(:,:,3)/4);

% imshow(ycbcr2rgb(Y_d));
imwrite(ycbcr2rgb(Y_d),'output.jpeg')

% DCT compress using chebfun(dct, idct)
A = zeros(size(Y_d));
B = A;
for channel = 1:3
    for j = 1:8:size(Y_d,1)-7
        for k = 1:8:size(Y_d,2)-7
            II = Y_d(j:j+7,k:k+7,channel);
            freq = dct(dct(II).').';
            freq = 4.*round(freq./4);
            A(j:j+7,k:k+7,channel) = freq;
            B(j:j+7,k:k+7,channel) = idct(idct(freq).').';
        end
    end
end
% Huffman
b = A(:);
b = b(:);
b = sqrt(real(b).*real(b) + imag(b).*imag(b));
b(b==0)=[];  %remove zeros.
b = floor(255*(b-min(b))/(max(b)-min(b)));
symbols = unique(b);
N = histcounts(b, length(symbols));
prob = N /length(b);
dict = huffmandict(symbols, prob);
enco = huffmanenco(b, dict);
FinalCompressedImage = length(enco);
FinalCompressedImage/ImageSize

B = sqrt(real(B).*real(B) + imag(B).*imag(B));
% imshow(ycbcr2rgb(uint8(B)));
imwrite(ycbcr2rgb(uint8(B)),'output1.jpeg')
