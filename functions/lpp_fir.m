function signal_filtered=lpp_fir(signal)

%lpp_interpolate: FIR filters the input signal
%Example: accFilt = lpp_fir(accRaw)
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%  signal = Matrix with rows being the time axis (one time series per column).

% -------------------------------------------------------------------------------------------------------
% Output:
%   signal_filtered = FIR filtered signal.
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Victor Alari & Jan-Victor Björkqvist (2021)
% -------------------------------------------------------------------------------------------------------

%% Define FIR coefficients
b=[-5.62065945694406e-05,-9.43161550565129e-05,-8.35069973097448e-05,-0.000143655719150712,-0.000157416511528740,-0.000202298023946117,-0.000219206650066600,-0.000243285904267220,-0.000243659707344772,-0.000235396122658727,-0.000202168062906202,-0.000150685378625482,-7.34678002526376e-05,2.46403586859672e-05,0.000144391438954099,0.000279285931863964,0.000424335170435622,0.000570039649314598,0.000706940881631735,0.000823121803101084,0.000906914492088748,0.000946257832291961,0.000930605077778791,0.000851197803319824,0.000702516340797229,0.000482833970544238,0.000195189058184651,-0.000152268899583263,-0.000545954986476315,-0.000967071005227396,-0.00139208559995231,-0.00179371295811997,-0.00214221880075545,-0.00240712022972858,-0.00255913010049722,-0.00257229800788284,-0.00242618602171739,-0.00210796215229419,-0.00161424124212488,-0.000952533027462805,-0.000142146222749227,0.000785567006635871,0.00178772091106703,0.00281120787549942,0.00379481719099871,0.00467211086614773,0.00537495559131232,0.00583755699397744,0.00600079763379614,0.00581664244461399,0.00525235092809322,0.00429422453367309,0.00295062363727977,0.00125401100719535,-0.000738181896280765,-0.00294401492728521,-0.00525890721905926,-0.00755891797661133,-0.00970536291882645,-0.0115506067688131,-0.0129447943459848,-0.0137432146063613,-0.0138139380032169,-0.0130453317882342,-0.0113530433257372,-0.00868604997910204,-0.00503140610743290,-0.000417372231896211,0.00508531388079588,0.0113641732931063,0.0182677753417444,0.0256105177667848,0.0331792260807117,0.0407412984417897,0.0480540325611426,0.0548746994651667,0.0609708797580239,0.0661305546241274,0.0701714479384853,0.0729491476647971,0.0743635927311380,0.0743635927311380,0.0729491476647971,0.0701714479384853,0.0661305546241274,0.0609708797580239,0.0548746994651667,0.0480540325611426,0.0407412984417897,0.0331792260807117,0.0256105177667848,0.0182677753417444,0.0113641732931063,0.00508531388079588,-0.000417372231896211,-0.00503140610743290,-0.00868604997910204,-0.0113530433257372,-0.0130453317882342,-0.0138139380032169,-0.0137432146063613,-0.0129447943459848,-0.0115506067688131,-0.00970536291882645,-0.00755891797661133,-0.00525890721905926,-0.00294401492728521,-0.000738181896280765,0.00125401100719535,0.00295062363727977,0.00429422453367309,0.00525235092809322,0.00581664244461399,0.00600079763379614,0.00583755699397744,0.00537495559131232,0.00467211086614773,0.00379481719099871,0.00281120787549942,0.00178772091106703,0.000785567006635871,-0.000142146222749227,-0.000952533027462805,-0.00161424124212488,-0.00210796215229419,-0.00242618602171739,-0.00257229800788284,-0.00255913010049722,-0.00240712022972858,-0.00214221880075545,-0.00179371295811997,-0.00139208559995231,-0.000967071005227396,-0.000545954986476315,-0.000152268899583263,0.000195189058184651,0.000482833970544238,0.000702516340797229,0.000851197803319824,0.000930605077778791,0.000946257832291961,0.000906914492088748,0.000823121803101084,0.000706940881631735,0.000570039649314598,0.000424335170435622,0.000279285931863964,0.000144391438954099,2.46403586859672e-05,-7.34678002526376e-05,-0.000150685378625482,-0.000202168062906202,-0.000235396122658727,-0.000243659707344772,-0.000243285904267220,-0.000219206650066600,-0.000202298023946117,-0.000157416511528740,-0.000143655719150712,-8.35069973097448e-05,-9.43161550565129e-05,-5.62065945694406e-05];


%% Parsing input
p = inputParser;
validMatrix = @(x) isnumeric(x) && (size(x,1)>max(size(b))); 
addRequired(p,'signal',validMatrix);
parse(p,signal);
p.Results; % diagnostic

%% Do filtering

[N,M]=size(p.Results.signal);  
signal_filtered=zeros(N,M);
for col=1:M
signal_filtered(:,col)=filter(b,1,p.Results.signal(:,col));
end
signal_filtered=signal_filtered((length(b)+1):end,:); %Don't output first n points
