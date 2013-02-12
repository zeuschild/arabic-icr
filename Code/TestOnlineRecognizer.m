function [ output_args ] = TestOnlineRecognizer(  )
%TESTONLINERECOGNIZER Summary of this function goes here
%   Detailed explanation goes here

global LettersDataStructure;
TestSetFolder = 'C:\OCRData\GeneratedWords';
LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');

OutputImages = true;
if (OutputImages==true)
    fig = figure();
    cl = clock;
    ax = axes();
    OutputFolder = ['C:\OCRData\TestOutput',num2str(cl(5)),'\'];
    if(~exist(OutputFolder,'dir'))
        mkdir(OutputFolder);
    end
end
clc;
correctRec = 0;
correctSeg = 0;
count = 0;
TestSetWordsFolderList = dir(TestSetFolder);
for i = 3:length(TestSetWordsFolderList)
    current_object = TestSetWordsFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')
        sequence = dlmread([TestSetFolder,'\',FileName]);
        disp(' ')
        disp(['Word  ',num2str(count),': ',FileName])
        RecState = SimulateOnlineRecognizer( sequence );
        [CorrectNumLetters, CorrectRecognition] = correctRecognition(RecState,strrep(FileName, '.m', ''));
        
        %Collect Statistics
        count=count+1;
        if (CorrectRecognition==true)
            correctRec = correctRec+1;
        else
            disp ('===>error Recognition')
            GetCandidatesFromRecState( RecState );
        end
        if (CorrectNumLetters==true)
            correctSeg = correctSeg+1;
        else
            disp ('===>error Segmentation')
        end
        
        %Output letters images to folder
        if (CorrectRecognition == false && OutputImages==true)
            WordFolder =[OutputFolder,'\',FileName];
            mkdir(WordFolder);
            for k=1:RecState.LCCPI
                if (k==1)
                    startIndex = 1;
                else
                    BLCCPP = RecState.CriticalCPs(k-1).Point;
                    startIndex = BLCCPP;
                end
                LCCP =  RecState.CriticalCPs(k);
                endIndex = LCCP.Point;
                plot (ax, RecState.Sequence(startIndex:endIndex,1),RecState.Sequence(startIndex:endIndex,2),'LineWidth',3);
                hold on;
                scatter (ax, RecState.Sequence(startIndex:endIndex,1),RecState.Sequence(startIndex:endIndex,2),'LineWidth',3);
                hold off;
                PrevDir = pwd;
                cd(WordFolder);
                saveas(ax,num2str(k),'jpg');
                cd (PrevDir);
            end
        end
    end
end

SegmentationRate = correctSeg/count*100
RecognitionRate = correctRec/count*100
end


function [CorrectNumLetters, CorrectRecognition] = correctRecognition(RecState,Word)
CorrectRecognition=true;
CorrectNumLetters=true;

if (RecState.LCCPI~=size(Word))
    CorrectNumLetters = false;
    CorrectRecognition = false;
    return;
end
for i=1:RecState.LCCPI
    LCCP =  RecState.CriticalCPs(i);
    CurrCan = LCCP.Candidates(:,1);
    wasRecognized = false;
    for j=1:size(CurrCan,1)
        if (strcmp(CurrCan{j}{1},Word(i)))
            wasRecognized = true;
        end
    end
    if (wasRecognized==false)
        CorrectRecognition = false;
        return;
    end
end
end
