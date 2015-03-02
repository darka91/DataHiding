%add sqlite driver
addpath ~/Dev/matlab-sqlite3-driver/
%load database
sqlite3.open('/Users/darka/Dev/DataHiding/Code/cache/articles.db');
imgs_base_from_sql = sqlite3.execute('select * from image where article_id in (select id from article where is_base = 1);');
imgs_corr_from_sql = sqlite3.execute('select * from image where article_id in (select id from article where is_base = 0);');

disp('load images base');
%load images base
cont = 1;
for img=imgs_base_from_sql

tempimage = imread(strcat('/Users/darka/Dev/DataHiding/Code/',img.local_path));
tempimagegray = rgb2gray(tempimage);
points1 = detectSURFFeatures(tempimagegray);
[f1, vpts1] = extractFeatures(tempimagegray, points1);

imgs_base(cont) = struct('sql_result',img,'features',f1,'image',tempimagegray);
cont = cont +1;
end

%now all the images and the features are in the imgs_base list

%load correlated images
disp('load correlated images');
cont = 1;
for img=imgs_corr_from_sql

tempimage = imread(strcat('/Users/darka/Dev/DataHiding/Code/',img.local_path));
tempimagegray = rgb2gray(tempimage);
points1 = detectSURFFeatures(tempimagegray);
[f1, vpts1] = extractFeatures(tempimagegray, points1);

imgs_corr(cont) = struct('sql_result',img,'features',f1, 'image', tempimagegray);
cont = cont +1;
end


%now all the images and the features are in the imgs_corr list

disp('Comparing images');
cont=0;
%compare images
for imgbase=imgs_base
for imgcorr=imgs_corr
%SURF part
f1 = imgbase.features;
f2 = imgcorr.features;
indexPairs = matchFeatures(f1, f2) ;
S= size(indexPairs);
S = S(1);

%correlation part
img1 = imgbase.image;
img2 = imgcorr.image;
img2 = imresize(img2,size(img1));
C = corr2(img1, img2);

clc;
disp(cont);
sqlite3.execute('insert into comparated_image values(1,?,?,?,?,?,?,?)',imgbase.sql_result.id,imgbase.sql_result.local_path,imgcorr.sql_result.id,imgcorr.sql_result.local_path,S,C,2);
cont= cont +1;
end
end