%{
    launchsystem.m
    EGR 103 Fall '19 - Ping Pong Ball Launcher (with Dr. Blackburn-Lynch)
    Team 002 - Team Rocket
    Vision System & Launch System Code Integration

    Authors:    Oreoluwa Olukotun, Jared Hyde
    Date:       December 11, 2019
    Desc:       This script integrates the vision system and launch system code for the ping pong
                ball launcher.
    Updated:    12/11/2019 12:32 AM jh

    ---------------------------------------------------------------------------------------------------------
    -----------------------------------------   READ ME     -------------------------------------------------
    ---------------------------------------------------------------------------------------------------------

    The following MATLAB add-ons are required for this program to execute:
        - MATLAB Support Package for USB Webcams <by MathWorks Image Acquisition Toolbox Team> <version 18.1.1 or later>
        - Image Processing Toolbox <by MathWorks> <version 10.2 or later>
        - MATLAB Support Package for Arduino Hardware <by MathWorks MATLAB Hardware Team> <version 18.1.1 or later>

    The MATLAB version used for this program was R2018a, but can be used with newer versions. 
%}

% do not remove lines 26, 27 -- will abruptly stop program!
clear   % removes all variables from the current workspace, releasing them from system memory.
clc     % clears the contents of the command window

Connect_Arduino()   % file must be in folder path for rest of script to execute!
                    % will automatically find ardunio as long as it is connected to PC
                    % no need to delcare COM port or board name!

%---------------------------------------------------------------------------
%                           BEGIN VISION SYSTEM CODE
%---------------------------------------------------------------------------

% assigns cam to webcam 
cam = webcam('USB2.0 PC CAMERA');   % use 'webcamlist' to find available PC webcams
%                                     you can replace with webcam name with the name of the webcam of your choice
preview(cam); % shows what the camera sees
% 
% timer for picture at 10 seconds
% 
pause(10);
% 
% takes picture
img = snapshot(cam);
% 
imwrite (img, 'visiondemo3mwrite.png'); % 'visiondemo3mwrite.png' must be in file path! (lines 49, 51)

yourImage = imread ('visiondemo3mwrite.png');
imshow(yourImage);
imtool(yourImage);

%Finds circles & their radii in image that fit the description of parameters
[centers,radii] = imfindcircles(yourImage,[16 30],'ObjectPolarity','dark',...
   'Sensitivity', 0.92);

%16 30 (for 1m) - radius range
%[13 25] (for 2 & 3m) - radius range

h = viscircles(centers,radii); %displays the image with circles
centerOfImage = [320 240]; % center of image with total pixels

sortedCoords = sortrows(centers,1); %this sorts the array by the X coordinates

%finds the center using diagonal
% gets the x and y values of both the upper left circle and lower right
% circle
%uses distance formula to find it
midpointX = (sortedCoords (1,1)+ sortedCoords(4,1))/2; 
midpointY = (sortedCoords (1,2)+ sortedCoords(4,2))/2;
centerTarg = [midpointX midpointY]; % center of the target

disp (centerTarg); % shows the value of centerTarg

HorizontalD = sortedCoords(3,1) - sortedCoords(1,1); % horizontal distance between top circles
VerticalD = sortedCoords (2,2) - sortedCoords(1,2); % vertical distance between left side circles

fprintf("HorizontalD ="); 
disp (HorizontalD); 

fprintf("VerticalD =");
disp(VerticalD);

DistanceFromCamera = (VerticalD - 232.38)/ (-43.757); % equation gotten from calibration 
%determines the targets distance from the camera

%gets the distance from the center of the image to the center of target ,
DistanceFromCenterToTarget = sqrt((centerOfImage(1,1)-centerTarg(1,1))^2 +(centerOfImage(1,2)-centerTarg(1,2))^2);

%closePreview(); %closes what camera sees
%Angle
%gotten from tan inverse 
Angle = atan(DistanceFromCenterToTarget/DistanceFromCamera) * 57.2958; % multiplying to change to degrees
%ArduinoAngle = (Angle / pi); %Angle converted for Arduino 
%used pi because 180 servo and 180 is pi in radians

fprintf("DistanceFromCamera = ");
disp(DistanceFromCamera);

fprintf("DistanceFromCenterToTarget=");
disp(DistanceFromCenterToTarget);

fprintf("Angle = ");
disp(Angle);

%fprintf ("ArduinoAngle=");
%disp (ArduinoAngle);

%y = -43.757x + 232.38 - equation distance

%---------------------------------------------------------------------------
%                           BEGIN LAUNCH SYSTEM CODE
%---------------------------------------------------------------------------

% ,'MinPulseDuration',700*10^-6,'MaxPulseDuration',2300*10^-6   **deprecated**

%{
    s1 = servo motor #1
        - 180 degree servo
        - connected on D9
        - vertical motion
        - support for servo... deprecated???
        - manually adjusted input (degree of motion)
    s2 = servo motor #2
        - 180 degree servo
        - connected on D10
        - horizontal motion
        - degree of motion provided based on VS computation
    s3 = servo motor #3
        - 360 degree servo
        - connected on D11
        - fires ball
        - automated, manually triggered
%}

s1 = servo(a, 'D9');
s2 = servo(a, 'D10');
s3 = servo(a, 'D11');

inputPosition1 = 'Write position for SERVO 1 (in degrees) >> ';
%inputPosition2 = 'Write position for SERVO 2 (in degrees) >> ';
%inputPosition3 = 'Write position for SERVO 3 (in degrees) >> ';

fprintf ('\n')

getPosition1 = input (inputPosition1);
    % entry validation
    while getPosition1 < 0 && getPosition1 > 180
        disp ('The provided entry is invalid. Enter an angle between 0 and 180 degrees.\n');
        input (inputPosition1);
    end


getPosition2 = Angle; % Angle calculated from vision system code

%{
getPosition2 = input (inputPosition2);
    % entry validation
    while getPosition1 < 0 && getPosition1 > 180
        disp ('The provided entry is invalid. Enter an angle between 0 and 180 degrees.\n');
        input (inputPosition2);
    end
%}

%getPosition3 = input (inputPosition3);

setPosition1 = getPosition1 / 180;
setPosition2 = getPosition2 / 180;
%setPosition3 = getPosition3;

%pause (0.1);

writePosition(s1, setPosition1);
writePosition(s2, setPosition2);
%writePosition(s3, setPosition3);



