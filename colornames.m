function [clr,rgb] = colornames(palette,varargin)
% Convert between RGB values and color names: from RGB to names, and names to RGB.
%
% (c) 2017 Stephen Cobeldick
%
% Easily convert between RGB values and color names, in both directions!
%
% COLORNAMES matches the input colors (either names or an RGB map) to colors
% from the requested palette. It returns both the color names and RGB values.
%
%%% Syntax:
%  palettes = colornames()
%  names = colornames(palette)
%  names = colornames(palette,RGB)
%  names = colornames(palette,RGB,deltaE)
%  names = colornames(palette,names)
%  names = colornames(palette,name1,name2,...)
% [names,RGB] = colornames(palette,...)
%
%%% RGB inputs:
% * Accepts multiple RGB values in a standard MATLAB Nx3 colormap.
% * Choice of color distance (deltaE) calculation, any one of:
%   'RGB', 'CMCl:c', 'CIE76', 'CIE94' (default), or 'CIEDE2000'.
%   For info on deltaE: https://en.wikipedia.org/wiki/Color_difference
% Note that palettes with sparse colors can produce unexpected matches.
%
%%% Color name inputs:
% * Accepts multiple color names (in one cell array, or as separate inputs).
% * Case-insensitive color name matches, e.g. 'Blue' == 'blue' == 'BLUE'.
% * Allows optional space characters between the color name words.
% * Allows CamelCase to specify color names with space characters in them.
% * Palettes with index numbers may be specified by the number: e.g.: '5'.
% * Palettes Alphabet, MATLAB, and Natural also match the initial letter to
%   the color name (except for 'Black' which is matched by 'k').
%
% See also PLOT PATCH SURF RGBPLOT COLORMAP BREWERMAP CUBEHELIX LBMAP CPRINTF NATSORT
%
%% Space Characters in Color Names %%
%
% Most palettes use CamelCase in the color names: COLORNAMES will match
% the input names with any character case or spaces between the words, e.g.:
% 'Sky Blue' == 'SKY BLUE' == 'sky blue' == 'SkyBlue' == 'SKYBLUE' == 'skyblue'.
%
% Palettes Foster and xkcd include spaces: clashes occur if the names are
% converted to one case (e.g. lower) and the spaces removed. To make these
% names more convenient to use, CamelCase is equivalent to words separated
% by spaces, e.g.: 'EggShell' == 'Egg Shell' == 'egg shell' == 'EGG SHELL'.
% Note this is a different color to 'Eggshell' == 'eggshell' == 'EGGSHELL'.
%
% In xkcd the forward slash ('/') also distinguishes between different
% colors, e.g.: 'Blue/Green' is not the same as 'Blue Green' (== 'BlueGreen').
%
%% Index Numbers in Color Names %%
%
% Palettes with a leading index number (e.g. AppleII, BSC381, CGA, RAL, etc)
% can also use just the index number or words to select a color, e.g.:
% '5' == 'Blue Flower' == 'BLUE FLOWER' == 'BlueFlower' == '5 Blue Flower'
% And for the palettes with spaces, CamelCase is also equivalent to words
% separated by spaces, e.g.: '5BlueFlower' == '5 Blue Flower' == '5 blue flower'
%
%% Initial Letter Color Name Abbreviations %%
%
% Palettes Alphabet, MATLAB, and Natural also match the initial letter to
% the color name (except for 'Black' which is matched by 'k'), e.g.:
% 'b' == 'Blue', 'y' =='Yellow', 'M' == 'Magenta', 'k' == 'Black'.
%
%% Examples %%
%
% colornames() % list all supported palettes
% ans =
%     'Alphabet'
%     'AmstradCPC'
%     'AppleII'
%     'BSC381'
%     'Bang'
%     'CGA'
%     'CSS'
%     'Crayola'
%     'Foster'
%     'HTML4'
%     'ISCC'
%     'Kelly'
%     'MATLAB'
%     'MacBeth'
%     'Natural'
%     'R'
%     'RAL'
%     'Resene'
%     'ResistorBands'
%     'ResistorDigit'
%     'SVG'
%     'Wikipedia'
%     'Wolfram'
%     'X11'
%     'dvips'
%     'xcolor'
%     'xkcd'
%
% colornames('HTML4') % all color names for one palette
%  ans =
%     'Aqua'
%     'Black'
%     'Blue'
%     'Fuchsia'
%     'Gray'
%     'Green'
%     'Lime'
%     'Maroon'
%     'Navy'
%     'Olive'
%     'Purple'
%     'Red'
%     'Silver'
%     'Teal'
%     'White'
%     'Yellow'
%
% [clr,rgb] = colornames('HTML4', 'PURPLE', 'yellow')
%  clr =
%     'Purple'
%     'Yellow'
%  rgb =
%      0.50196          0    0.50196
%            1          1          0
%
% [clr,rgb] = colornames('HTML4', [0.4,0.1,0.6; 0.8,0.9,0.2])
%  clr =
%     'Purple'
%     'Yellow'
%  rgb =
%      0.50196          0    0.50196
%            1          1          0
%
% [clr,rgb] = colornames('MATLAB');
% [char(strcat(clr,{'  '})),num2str(rgb)]
%  ans =
%  Black    0  0  0
%  Blue     0  0  1
%  Cyan     0  1  1
%  Green    0  1  0
%  Magenta  1  0  1
%  Red      1  0  0
%  White    1  1  1
%  Yellow   1  1  0
%
% colornames('MATLAB','c','m','y','k')
% ans = 
%     'Cyan'
%     'Magenta'
%     'Yellow'
%     'Black'
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
%  palette = String, the name of a supported palette, e.g.: 'CSS'.
% The optional input/s can be names or RGB values. Names can be either:
%  names  = Cell of Strings, any number of supported color names.
%  name1,name2,... = Strings, any number of supported color names.
% RGB values in a matrix, with optional choice of color-distance deltaE:
%  RGB    = Numeric Matrix, size Nx3, each row is an RGB triple (0<=rgb<=1).
%  deltaE = String token, *'CIE94', 'CIE76', 'CMCl:c', 'RGB', or 'CIEDE2000'.
%
%%% Outputs:
%  clr = Cell of Strings, size Nx1, the color names that best match the inputs.
%  rgb = Numeric Matrix, size Nx3, RGB values corresponding to names in <nam>.
%
%[clr,rgb] = colornames(palette,names OR name1,name2,..)
% OR
%[clr,rgb] = colornames(palette,RGB,*deltaE)

%% Read Palette Data %%
%
% Store data structure to make accessing faster:
persistent data
% Load data on first call:
if isempty(data)
	data = load('colornames.mat');
end
%
clr = fieldnames(data);
dtE = {'CIEDE2000','CIE94','CIE76','CMCl:c','RGB'};
%
%% Return All Palette Names %%
%
if nargin==0
	rgb = struct('deltaE',{dtE}, 'invgamma',@cnGammaInv, 'rgb2hsv',@cnRGB2HSV,...
		'rgb2xyz',@cnRGB2XYZ, 'xyz2lab',@cnXYZ2Lab, 'lab2lch',@cnLab2LCh);
	return
end
%
%% Retrieve a Palette's Color Names and RGB %%
%
ord = {'first','second','third'};
%
assert(ischar(palette)&&isrow(palette),'The %s input must be a string.',ord{1})
ids = strcmpi(palette,clr);
assert(any(ids),'Palette ''%s'' is not supported. Call COLORNAMES() to list all palettes.',palette)
pal = clr{ids};
%
clr = data.(pal).names;
rgb = double(data.(pal).rgb) / data.(pal).scale;
%
%% Match Input RGB to Palette Colors %%
%
isCoS = @(C)cellfun('isclass',C,'char') & cellfun('size',C,1)<2 & cellfun('ndims',C)<3;
%
if nargin==1 % return complete palette
	return
elseif isnumeric(varargin{1}) % RGB values
	idx = cnClosest(dtE,ord,rgb,varargin{1},varargin(2:end));
	clr = clr(idx,:);
	rgb = rgb(idx,:);
	return
elseif iscell(varargin{1}) % color names in a cell array
	assert(nargin==2,'Too many inputs: only one cell array of color names is allowed.')
	arg = varargin{1}(:);
	assert(all(isCoS(arg)),'Every cell element must contain one string (1xN char).')
else % individual color names
	arg = varargin(:);
	assert(all(isCoS(arg)),'Input arguments must be strings (1xN char), or an RGB map (Nx3 num).')
end
%
%% Match Input Strings to Palette Color Names %%
%
% Split CamelCase color names into separate words:
rgx = regexprep(clr,'([a-z])([A-Z])','$1 $2');
% Split leading indices from color name words:
if data.(pal).indices
	spl = regexp(rgx,'(\d+) ?(.*)','once','tokens');
	spl = vertcat(spl{:});
	rgx = [rgx;spl(:)];
end
% Add initials (selected palettes only):
rgx = [rgx;data.(pal).initial];
% Convert palette color names to regular expressions:
rgx = strcat('^',regexptranslate('escape',rgx),'$');
rgx = regexprep(rgx,{'([Gg])r[ae]y',' '},{'$1r[ae]y',' ?'});
% Use regular expression to match input strings to palette color names:
idm = cellfun(@(s)~cellfun('isempty',regexpi(s,rgx,'once')),arg,'UniformOutput',false);
idn = cellfun(@nnz,idm);
% Any unmatched input strings throw an error:
if any(idn==0)
	cnNoMatch(pal,clr,arg(idn==0))
end
% If any input strings match multiple regexps, pick the best color name match:
idz = idn>1;
fun = @(a,v)cnPickBest(data.(pal),clr,a,v);
idm(idz) = cellfun(fun, arg(idz),idm(idz), 'UniformOutput',false);
% Get palette indices of matched input strings:
idx = cellfun(@(v)find(v),idm);
idx = 1+mod(idx-1,numel(clr));
%
clr = clr(idx,:);
rgb = rgb(idx,:);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%colornames
function idm = cnPickBest(sub,clr,gra,idm)
% Pick the closest color name to match the given input string <gra>.
%
assert(all(size(clr)==size(idm)),'Not implemented for palettes with indices.')
%
gra = regexprep(gra,sub.regexp,sub.replace);
nme = cellfun(@(s)cnEdits(s,gra),clr(idm));
[~,ide] = min(nme); % using |min| guarantees one index is returned.
tmp = false(size(nme));
tmp(ide) = true;
idm(idm) = tmp;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnPickBest
function cnNoMatch(pal,clr,gra)
% Find palette color names closest to <gra> strings, and print an error message.
%
% Sort names into order of closest to furthest match, measure name lengths:
[~,idx] = cellfun(@(s)sort(cellfun(@(n)cnEdits(s,n),clr)),gra,'UniformOutput',false);
lft = cellfun(@(s)sprintf('%-13s ->',s),gra,'UniformOutput',false);
cus = cellfun(@(s,x)cumsum([2+numel(s);4+cellfun('length',clr(x))]),lft,idx,'UniformOutput',false);
try
	N = get(0,'CommandWindowSize');
catch %#ok<CTCH>
	N = 100; % How to get this value for R2014b + ?
end
eos = @(s)[s(1:end-1),'.'];
% Join names together without exceeding the command window width:
idn = cellfun(@(v)find(v<=N(1),1,'last'),cus,'UniformOutput',false);
rgt = cellfun(@(x,n)sprintf(' ''%s'',',clr{x(1:n-1)}),idx,idn,'UniformOutput',false);
tmp = cellfun(eos, strcat(lft,rgt), 'UniformOutput',false);
%
str = sprintf('%s\n',tmp{:});
str = sprintf('Some color names that are similar to those input strings:\n%s',str);
%
% Print error message with color names similar to the input strings:
pal = sprintf('''%s''',pal);
txt = eos(sprintf(' ''%s'',',gra{:}));
error(['The palette %1$s does not support these colors:%2$s\n\n%3$s\n'...
	'Call COLORNAMES(%1$s) to list all color names for that palette,\n'...
	'or COLORNAMES_VIEW(%1$s) to view the palette listed in a figure,\n'...
	'or COLORNAMES_CUBE(%1$s) to view the palette in a 3D cube.'],pal,txt,str) %#ok<SPERR>
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnNoMatch
function d = cnEdits(S1,S2)
% Wagner�Fischer algorithm to calculate the edit distance / Levenshtein distance.
%
N1 = 1+numel(S1);
N2 = 1+numel(S2);
%
D = zeros(N1,N2);
D(:,1) = 0:N1-1;
D(1,:) = 0:N2-1;
%
for r = 2:N1
	for c = 2:N2
		D(r,c) = min([D(r-1,c)+1, D(r,c-1)+1, D(r-1,c-1)+~strcmpi(S1(r-1),S2(c-1))]);
	end
end
d = D(end);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnEdits
function idx = cnClosest(dtE,ord,rgb,arg,typ)
% Use color difference (deltaE) to identify the closest colors to input RGB values.
%
dtS = sprintf(' ''%s'',',dtE{:});
%
switch numel(typ)
	case 0
		typ = 'CIE94';
	case 1
		typ = typ{1};
		assert(ischar(typ)&&isrow(typ),[...
			'If the %s argument is an RGB map, then the optional %s\n'...
			'argument can select the color difference (deltaE) metric.\n'...
			'It must be one of:%s\b'],ord{2},ord{3},dtS)
	otherwise
		error('Too many input arguments. See help for information on input options.')
end
assert(ismatrix(arg)&&size(arg,2)==3&&isreal(arg)&&all(0<=arg(:)&arg(:)<=1),...
	'The %s input argument can be a map of RGB values (size Nx3).',ord{2})
%
%% Calculate the Color Difference (deltaE) %%
%
if strcmpi(typ,'RGB')
	[~,idx] = cellfun(@(v)min(sum(bsxfun(@minus,rgb,v).^2,2)),num2cell(arg,2));
	return
end
%
lab = cnXYZ2Lab(cnRGB2XYZ(rgb));
gra = cnXYZ2Lab(cnRGB2XYZ(arg));
%
switch upper(typ)
	case 'CIEDE2000'
		[~,idx] = cellfun(@(v)min(sum(cnCIE2k(lab,v),2)),num2cell(gra,2));
	case 'CIE94'
		[~,idx] = cellfun(@(v)min(sum(cnCIE94(lab,v),2)),num2cell(gra,2));
	case 'CMCL:C'
		[~,idx] = cellfun(@(v)min(sum(cnCMClc(lab,v),2)),num2cell(gra,2));
	case {'CIE76','LAB'}
		[~,idx] = cellfun(@(v)min(sum(bsxfun(@minus,lab,v).^2,2)),num2cell(gra,2));
	otherwise
		error(['The %s input, color difference (deltaE) metric ''%s'', is not supported.'...
			'\nThe supported color difference metrics are:%s\b'],ord{3},typ,dtS)
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnClosest
function rgb = cnGammaInv(rgb) % [Nx3] <- (Nx3)
% Inverse gamma transform of RGB data.
%
idx = rgb <= 0.0404482362771076;
rgb(idx) = rgb(idx)/12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055)/1.055).^2.4);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnGammaInv
function xyz = cnRGB2XYZ(rgb) % [Nx3] <- (Nx3)
% Convert a matrix of RGB values to XYZ.
%
% Remember to include my license when copying my implementation.
xyz = cnGammaInv(rgb) * [... % colorant
	0.4360656738281250,0.2224884033203125,0.0139160156250000;...
	0.3851470947265625,0.7168731689453125,0.0970764160156250;...
	0.1430664062500000,0.0606079101562500,0.7140960693359375;...
	] * [... % transformation
	+1.00003273776446530e+0,+1.94861137216967560e-5,-1.06895905858800380e-5;...
	+1.65909673844090440e-5,+0.99999563134877756e+0,+1.80109293897307010e-5;...
	-5.32428793910688650e-5,-1.74761184963470590e-5,+0.99971634242247531e+0;...
	];
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnRGB2XYZ
function lab = cnXYZ2Lab(xyz) % [Nx3] <- (Nx3)
% Convert a matrix of XYZ values to CIELab.
%
% Remember to include my license when copying my implementation.
xyz = bsxfun(@rdivide,xyz,[0.964202880859375,1,0.82489013671875]);
idx = xyz>(6/29)^3;
F = idx.*(xyz.^(1/3)) + ~idx.*(xyz*(29/6)^2/3+4/29);
lab(:,2:3) = bsxfun(@times,[500,200],F(:,1:2)-F(:,2:3));
lab(:,1) = 116*F(:,2) - 16;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnXYZ2Lab
function lch = cnLab2LCh(lab) % [Nx3] <- (Nx3)
% Convert a matrix of CIELab values to LCh.
%
% Remember to include my license when copying my implementation.
lch(:,3) = cnAtan2d(lab(:,3),lab(:,2));
lch(:,2) = sqrt(sum(lab(:,2:3).^2,2));
lch(:,1) = lab(:,1);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnLab2LCh
function hsv = cnRGB2HSV(rgb) % [Nx3] <- (Nx3)
% Convert a matrix of RGB triples to HSV.
%
% Remember to include my license when copying my implementation.
rgb = cnGammaInv(rgb);
[V,X] = max(rgb,[],2);
S = V - min(rgb,[],2);
N = numel(S);
L = N*mod(X+0,3) + (1:N).';
R = N*mod(X+1,3) + (1:N).';
H = mod(2*(X-1)+(rgb(L)-rgb(R))./S,6);
S = S./V;
S(V==0) = 0;
H(S==0) = 0;
hsv = [60*H,S,V];
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnRGB2HSV
function LCHs = cnCIE94(v1,v2) % [Nx3] <- (Nx3,1x3)
% Return a matrix of CIE94 deltaE calculation values.
%
kLCH = [2,1,1]; % [1,1,1]
K012 = [0,0.048,0.014]; % [0,0.045,0.015]
Ca1 = sqrt(sum(v1(:,[2,3]).^2,2));
Ca2 = sqrt(sum(v2(:,[2,3]).^2,2));
% Remember to include my license when copying my implementation.
dHa = sqrt((v1(:,2)-v2(:,2)).^2 + (v1(:,3)-v2(:,3)).^2 - (Ca1-Ca2).^2);
LCHs = ([(v1(:,1)-v2(:,1)), (Ca1-Ca2), dHa] ./ ...
	bsxfun(@times, kLCH, (1 + bsxfun(@times, Ca1, K012)))).^2;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnCIE94
function LCHsR = cnCIE2k(v1,v2) % Nx4 <- (Nx3,1x3)
% Return a matrix of CIEDE2000 deltaE calculation values.
%
kLCH = [1,1,1];
Ca1 = sqrt(sum(v1(:,2:3).^2,2));
Ca2 = sqrt(sum(v2(:,2:3).^2,2));
% Remember to include my license when copying my implementation.
Cb = (Ca1+Ca2)/2;
Lb = (v1(:,1)+v2(:,1))/2;
tmp = 1-sqrt(Cb.^7 ./ (Cb.^7 + 25^7));
ap1 = v1(:,2) .* (1+tmp/2);
ap2 = v2(:,2) .* (1+tmp/2);
Cp1 = sqrt(ap1.^2 + v1(:,3).^2);
Cp2 = sqrt(ap2.^2 + v2(:,3).^2);
Cbp = (Cp1+Cp2)/2;
Cpp = Cp1.*Cp2;
idx = Cpp==0;
hp1 = cnAtan2d(v1(:,3),ap1);
hp2 = cnAtan2d(v2(:,3),ap2);
dhp = 180-mod(180+hp1-hp2,360);
dhp(idx) = 0;
Hbp = mod((hp1+hp2)/2 - 180*(abs(hp1-hp2)>180),360);
Hbp(idx) = hp1(idx)+hp2(idx);
T = 1-0.17*cosd(Hbp-30)+0.24*cosd(2*Hbp)+0.32*cosd(3*Hbp+6)-0.2*cosd(4*Hbp-63);
RT = -sind(60*exp(-((Hbp-275)/25).^2)) .* sqrt(Cbp.^7 ./ (Cbp.^7 + 25^7))*2;
SLCH = [(0.015*(Lb-50).^2)./sqrt(20+(Lb-50).^2), 0.045*Cbp, 0.015*Cbp.*T];
dLCH = [(v2(:,1)-v1(:,1)), (Cp2-Cp1), 2*sqrt(Cpp).*sind(dhp/2)] ./ ...
	bsxfun(@times, kLCH, 1 + SLCH);
LCHsR = [dLCH.^2, RT.*prod(dLCH(:,2:3),2)];
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnCIE2k
function LCHs = cnCMClc(v1,v2) % [Nx3] <- (Nx3,1x3)
% Return a matrix of CMC l:c deltaE calculation values.
%
Ca1 = sqrt(sum(v1(:,[2,3]).^2,2));
Ca2 = sqrt(sum(v2(:,[2,3]).^2,2));
% Remember to include my license when copying my implementation.
dHa = sqrt((v1(:,2)-v2(:,2)).^2 + (v1(:,3)-v2(:,3)).^2 - (Ca1-Ca2).^2);
SL = 0.040975*v1(:,1) ./ (1+0.01765*v1(:,1));
SL(v1(:,1)<16) = 0.511;
SC = 0.0638 * (1 + Ca1./(1+0.0131*Ca1));
h1 = cnAtan2d(v1(:,3),v1(:,2));
F = sqrt(Ca1.^4./(1900+Ca1.^4));
A = [0.36;0.56]; B = [0.4;0.2]; D = [35;168];
X = 1+(164<=h1 & h1<=345);
T = A(X) + abs(B(X).*cosd(h1+D(X)));
SH = SC .* (F.*T + 1 - F);
LCHs = ([(v2(:,1)-v1(:,1)), (Ca2-Ca1), dHa] ./ [SL,SC,SH]).^2;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnCMClc
function ang = cnAtan2d(Y,X)
ang = mod(360*atan2(Y,X)/(2*pi),360);
ang(Y==0 & X==0) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cnAtan2d