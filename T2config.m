
function T2opt = T2config(SetF)
%  T2config(SetF) returns optimal MCU clock divisor and closest frequency
%  SetF = Target Frequency
%  T2opt 1x4 vector [clock prescaler, Counter frequency, Count Period, Max Delay]
%  Displays MCU clock prescaler, OCR2A value, Set Frequency, Output Frequency
%

    Fcpu = 16e6;
    T2bits = 8;
    T2max = 2^8-1;
%    SetF = 500;
    SetP = 1 / SetF;
    T2(:,1) = [1; 8; 32; 64; 128; 256; 1024];
    T2(:,2) = Fcpu ./ T2(:,1);
    T2(:,3) = 1 ./ T2(:,2);
    T2(:,4) = 2^T2bits * T2(:,3);
    if (SetP > T2(end))
        printf(' Set Frequency: %f\n', SetF);
        printf(' Minimum Frequency on Timer 2: %f\n', 1 / T2(end));
        T2opt = []
        return
    else        
        T2opt = T2(T2(:,4) == min(T2(T2(:,4)>SetP,4)),:);

        Labels = { 'Prescaler' 'T2_Freq' 'T2_Period' 'Max_Period' };
        CL = columnLabels(Labels, 5, 15);
        displayTable(CL, T2opt);

        OCR2Atarget = SetP / T2opt(3) - 1;
        OCR2Aset = round(OCR2Atarget);
        printf(' MCUclk / %d\n', cast(T2opt(1), 'uint16'));
        printf(' OCR2A = %d\n', cast(OCR2Aset, 'uint8'));
        printf(' Set Frequency = %d\n', SetF);
        printf(' Output Frequency = %f\n', 1 / ((OCR2Aset + 1) * T2opt(3)));
    end
end
