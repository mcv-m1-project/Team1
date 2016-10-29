function [mask,split] = splitMask(pixelCandidates)
split = 9;
[r,c] = size(pixelCandidates);
imsplit=false;

%Check if we can discard part of the image.
%Firstly look into a vertical division. Check if any of the halfs are
%empty. If one of them is, check if one of their quarters is empty.
%If any of the halfs is empty, try with a horizontal split. If it doesn't
%discard any part of the image either, keep the entire image.

%First of all, check if there is not a signal in the middle of the image,
%so we can split it
if nnz(pixelCandidates(:,round(c/2)))==0 || nnz(pixelCandidates(:,round(c/2)+1))==0
    
    if nnz(pixelCandidates(:,1:round(c/2)))==0
        %Left half is empty
        if nnz(pixelCandidates(1:round(r/2),round(c/2)+1:end)) == 0
            %Upper quarter in right half is empty
            if nnz(pixelCandidates(round(r/2)+1:end,round(c/2)+1:end)) == 0
                %Bottom quarter in right half is also empty
                %All image is empty, do nothing
                mask = pixelCandidates;
                split = 0;
                return
            else
                %Bottom quarter in right half is NOT empty
                %A signal can only be in this quarter
                mask = pixelCandidates(round(r/2)+1:end,round(c/2)+1:end);
                split = 4;
                imsplit=true;
                return
            end
            
        else
            %Upper quarter in right half is NOT empty
            if nnz(pixelCandidates(round(r/2)+1:end,round(c/2)+1:end)) == 0
                %Bottom quarter in right half is empty. Keep only upper quarter
                mask = pixelCandidates(1:round(r/2),round(c/2)+1:end);
                imsplit=true;
                split = 2;
                return
            else
                %Bottom quarter in right half is NOT empty either.
                %Keep entire half
                mask = pixelCandidates(1:end,round(c/2)+1:end);
                imsplit=true;
                split = 6;
                return
            end
        end
    elseif nnz(pixelCandidates(:,round(c/2)+1:end))==0
        %Left half is NOT empty
        %Right half is empty
        if nnz(pixelCandidates(1:round(r/2),1:round(c/2))) == 0
            %Upper quarter in left half is empty
            %Then bottom quarter in left half is NOT empty, keep only this
            %quarter
            mask = pixelCandidates(round(r/2)+1:end,1:round(c/2));
            imsplit=true;
            split = 3;
            return
        else
            %Upper quarter in left half is NOT empty
            if nnz(pixelCandidates(round(r/2)+1:end,1:round(c/2))) == 0
                %Bottom quarter in left half is empty
                %Keep only upper quarter
                mask = pixelCandidates(1:round(r/2),1:round(c/2));
                imsplit=true;
                split = 1;
                return
            else
                %Bottom quarter in left half is NOT empty
                %Keep entire left half
                mask = pixelCandidates(1:end,1:round(c/2));
                imsplit=true;
                split = 5;
                return
            end
        end
    end
end
%If the image can't be split in vertical halfs, try horizontal
%Check if we can divide the image in horizontal halfs
if imsplit==false && (nnz(pixelCandidates(round(r/2),:))==0 || nnz(pixelCandidates(round(r/2)+1,:))==0)
    if nnz(pixelCandidates(1:round(r/2),:))==0
        %Upper half is empty, keep only the bottom one
        mask = pixelCandidates(round(r/2)+1:end,:);
        split = 8;
        return
    elseif nnz(pixelCandidates(round(r/2)+1,:))==0
        %Upper half is NOT empty
        %Bottom half is empty, keep only the upper one
        mask = pixelCandidates(1:round(r/2),:);
        split = 7;
        return
    else
        %None of the halfs are empty, keep the entire image
        mask = pixelCandidates;
        split = 9;
        return
    end
elseif imsplit==false
    %The image can't be split, keep the entire image
    mask = pixelCandidates;
    split = 9;
    return
end
end