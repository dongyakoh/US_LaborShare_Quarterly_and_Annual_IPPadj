# IPP_USLS_Quarterly (last updated on 11/26/2022)

This GibHub repository contains and regularly updates annual and quarterly labor share series for the U.S separately for the aggregate economy and the corporate sector. If you use our constructed time series of the U.S. labor share, please cite the source of the data as "updated series" from Koh, D., Santaeulalia-Llopis, R., and Zheng, Y. (2020). ``Labor Share Decline and Intellectual Property Products Capital,'' Econometrica, 88(6):2609–2628.
We provide two constructs of the labor share. First, we construct a labor share that imposes that all intellectual property products (IPP) income (i.e investment) is capital income which is what the BEA currently assumes (as of November 25, 2022). Second, alternatively, we treat IPP income as ambiguous income as proposed in (Koh et al., 2020), which is equivalent to treat IPP investment as an intermediate expense (i.e. what the BEA assumed before it started to capitalize software in 1999 and R&D and artistic originals in 2013). More details are provided in the PDF file of this repository.

In this repository, we include the following files and a folder:

(1) US_LS.xlsx: This is a spreadsheet with our annual (1948-2021) and quarterly (1948Q1-2021Q1) labor share (LS) series for the U.S. 

(2) The labor share series in (1) are computed using STATA do-files and raw data from NIPA and FAT that we provide in the "data_code" folder wich contains: 

    2.1. IPP_USLS_DATA_quarterly.xlsx: raw quarterly data fetched from NIPA and FAT to construct quarterly LS series for the U.S.
    2.2. IPP_USLS_DATA_annual.xlsx: raw annual data fetched from NIPA and FAT to construct annual LS series for the U.S.
    2.3. IPP_USLS_quarterly.do: STATA do-file that constructs quarterly LS series for the U.S. and generates the graphs in "The U.S. Labor Share.pdf"
    2.4. IPP_USLS_annual.do: STATA do-file that constructs quarterly LS series for the U.S. and generates the graphs in "The U.S. Labor Share and IPP.pdf"

(3) The "US_LaborShare_Updated.PDF" describes how we construct the labor share series for the aggregate economy and the corporate sector and provides updated graphs.