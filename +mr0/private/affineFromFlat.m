function affine = affineFromFlat(flat)
%AFFINEFROMFLAT Convert flat 12-element list to 3x4 affine matrix.
    if numel(flat) >= 12
        flat = double(flat(:));
        affine = [
            flat(1), flat(2), flat(3), flat(4);
            flat(5), flat(6), flat(7), flat(8);
            flat(9), flat(10), flat(11), flat(12)
        ];
    else
        affine = [
            2.5, 0.0, 0.0, -80.0;
            0.0, 2.5, 0.0, -80.0;
            0.0, 0.0, 2.5, 0.0
        ];
    end
end
