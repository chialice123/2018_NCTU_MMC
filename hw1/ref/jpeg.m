%set input image name
image_name = 'head.bmp'

%read image
I = imread(image_name);

%convert to uint8
I = im2uint8(I);

%convert different kind of image to RGB
if ndims(I) ~= 3
    I = cat(3, I, I, I);
end
ImageSize = 8*prod(size(I))

%Convert RGB to YCbCr
Y = rgb2ycbcr(I);

%Downsampling
Y_d = Y;
Y_d(:,:,2) = 2*round(Y_d(:,:,2)/2);
Y_d(:,:,3) = 2*round(Y_d(:,:,3)/2);

%Quantization table
Q = [16 11 10 16 24 40 51 61 ;
     12 12 14 19 26 28 60 55 ;
     14 13 16 24 40 57 69 56 ;
     14 17 22 29 51 87 80 62 ;
     18 22 37 56 68 109 103 77 ;
     24 35 55 64 81 104 113 92 ;
     49 64 78 87 103 121 120 101;
     72 92 95 98 112 100 103 99];

QC = [17 18 24 47 99 99 99 99 ;
     18 21 26 66 99 99 99 99 ; 
     24 26 56 99 99 99 99 99 ; 
     47 66 99 99 99 99 99 99 ; 
     99 99 99 99 99 99 99 99 ; 
     99 99 99 99 99 99 99 99 ; 
     99 99 99 99 99 99 99 99 ; 
     99 99 99 99 99 99 99 99];
 
% DCT
A = zeros(size(Y_d));
B = A;
for channel = 1:3
    for j = 1:8:size(Y_d,1)-7
        for k = 1:8:size(Y_d,2)-7
            II = Y_d(j:j+7,k:k+7,channel);
            freq = chebfun.dct(chebfun.dct(II).').';
            B(j:j+7,k:k+7,channel) = chebfun.idct(chebfun.idct(freq).').';
            
            % do the inverse at the same time:
        end
    end
end

%Quantization
for channel = 1:1
    for j = 1:8:size(Y_d,1)-7
        for k = 1:8:size(Y_d,2)-7
            freq = Q.*round(freq./Q);
            A(j:j+7,k:k+7,channel) = freq;
        end
    end
end

for channel = 2:3
    for j = 1:8:size(Y_d,1)-7
        for k = 1:8:size(Y_d,2)-7
            freq = QC.*round(freq./QC);
            A(j:j+7,k:k+7,channel) = freq;
        end
    end
end

%Huffman encoding
b = A(:);
b = b(:);
b(b==0)=[];  %remove zeros.
b = floor(255*(b-min(b))/(max(b)-min(b)));
symbols = unique(b);
prob = histcounts(b,length(symbols))/length(b);
dict = huffmandict(symbols, prob);
enco = huffmanenco(b, dict);
FinalCompressedImage = length(enco);

FinalCompressedImage/ImageSize

subplot(1,2,1)
imshow(I)
title('Original')
subplot(1,2,2)
imshow(ycbcr2rgb(uint8(B)));
title('Compressed')
Compressed_image = ycbcr2rgb(uint8(B));
imwrite(Compressed_image,'Compressed_image.jpeg');