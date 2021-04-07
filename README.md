# PosturalCorrection
An algorithm to reduce local seat pressure maxima. Computes a target pressure based on current/real-time postural input to inform a seat made from an array of individual air bladders.

# Steps
-     During a x-minute period, a pressure matrix reading is collected towards an average posture (over an entire static period between repositioning cycles) 
-     That average informs the repositioning algorithm of the large pressure centers, a mean pressure, and the average sum of interface pressures.
-      The first step in the repositioning algorithm is to collect all elements in the matrix that fall above the mean. To proportionally diminish these higher peaks, the difference between the maximum and mean is subtracted from the respective input, while also including scaling and weight parameters.
-      This step repeats for all elements in the 60x60 array, which itself repeats recursively until the adjusted maxima fall below a designed threshold.
-      Due to diminishing pressure maxima, the sum of pressure of the interface is less than the original and must be corrected to maintain full support of the patient’s weight.
-      Seen as the second step in the repositioning algorithm, all non-zero elements that fell below the mean were equally increased to incorporate the total interface area.
-      This “sum recovery” method differed from the first “peak reduction” step by its equal pressure increases. Local minima were not regarded the same as maxima due to their postural reasons and practical support capabilities. The sum recovery algorithm also incorporated a recursive design to iterate until the sum was equal to that of the initial input.
