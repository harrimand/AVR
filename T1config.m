

function T1opt = T1config(SetF)
%  T1config(SetF) returns optimal MCU clock divisor and closest frequency
%  SetF = Target Frequency
%  T1opt 1x4 vector [clock prescaler, Counter frequency, Count Period, Max Delay]
%  Displays MCU clock prescaler, OCR1A value, Set Frequency, Output Frequency
%

    Fcpu = 16e6;
    T1bits = 16;
    T1max = 2^16-1;
%    SetF = 500;
    SetP = 1 / SetF;
    T1(:,1) = [1; 8; 64; 256; 1024];
    T1(:,2) = Fcpu ./ T1(:,1);
    T1(:,3) = 1 ./ T1(:,2);
    T1(:,4) = 2^T1bits * T1(:,3);
    if (SetP > T1(end))
        printf(' Set Frequency: %f\n', SetF);
        printf(' Minimum Frequency on Timer 2: %f\n', 1 / T1(end));
        T1opt = []
        return
    else        
        T1opt = T1(T1(:,4) == min(T1(T1(:,4)>SetP,4)),:);

        Labels = { 'Prescaler' 'T1_Freq' 'T1_Period' 'Max_Period' };
        CL = columnLabels(Labels, 5, 15);
        displayTable(CL, T1opt);

        OCR1Atarget = SetP / T1opt(3) - 1;
        OCR1Aset = round(OCR1Atarget);
        printf(' MCUclk / %d\n', cast(T1opt(1), 'uint16'));
        printf(' OCR1A = %d\n', cast(OCR1Aset, 'uint16'));
        printf(' Set Frequency = %d\n', SetF);
        printf(' Output Frequency = %f\n', 1 / ((OCR1Aset + 1) * T1opt(3)));
    end
end
