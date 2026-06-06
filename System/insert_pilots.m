function Xpos = insert_pilots(dataSymbols,pilotSymbols,pilotIdx,numActive)
%INSERT_PILOTS Insert pilots into positive-frequency active DCO-OFDM bins.
Xpos = zeros(numActive,1);
mask = true(numActive,1);
mask(pilotIdx) = false;
if numel(dataSymbols) ~= nnz(mask)
    error('insert_pilots:DataLength','Expected %d data symbols, got %d.',nnz(mask),numel(dataSymbols));
end
Xpos(pilotIdx) = pilotSymbols(:);
Xpos(mask) = dataSymbols(:);
end
