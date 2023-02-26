

/*
Cleaning Data in SQL Queries
*/


Select *
From ProfileProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format , removing timestamp

Select Convert(Date,SaleDate) as SaleDate
From ProfileProject..NashvilleHousing

Alter Table profileproject..NashvilleHousing
add SaleDateConverted Date;

Update ProfileProject..NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select *
from ProfileProject..NashvilleHousing



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
from ProfileProject..NashvilleHousing
order by ParcelID
where PropertyAddress is null

SELECT NH1.[UniqueID ]
     , NH1.ParcelID
	 , NH1.PropertyAddress
	 , NH2.[UniqueID ]
	 , NH2.ParcelID
	 , NH2.PropertyAddress
	 -- ISNULL or Coalesce can be used
	 , ISNULL(nh1.propertyaddress,nh2.PropertyAddress) 
	 , COALESCE(nh1.PropertyAddress,nh2.propertyaddress)
FROM ProfileProject..NashvilleHousing NH1
INNER JOIN  ProfileProject..NashvilleHousing NH2
            ON NH1.ParcelID = NH2.ParcelID
			AND NH1.[UniqueID ] <> NH2.[UniqueID ]
Where NH1.PropertyAddress is null

Update NH1
SET propertyaddress = ISNULL(nh1.propertyaddress,nh2.PropertyAddress)
from ProfileProject..NashvilleHousing NH1
inner join  ProfileProject..NashvilleHousing NH2
            ON NH1.ParcelID = NH2.ParcelID
			AND NH1.[UniqueID ] <> NH2.[UniqueID ]



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from ProfileProject..NashvilleHousing

SELECT SUBSTRING(PROPERTYADDRESS,1,CHARINDEX(',',PROPERTYADDRESS)-1) AS ADDRESS
     , SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PROPERTYADDRESS)+1,LEN(PROPERTYADDRESS)) AS CITY
FROM ProfileProject..NashvilleHousing



ALTER TABLE profileproject..nashvillehousing
ADD  PropertySplitAddress Nvarchar(255),
     PropertySplitCity  Nvarchar(255);


Update ProfileProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PROPERTYADDRESS,1,CHARINDEX(',',PROPERTYADDRESS)-1)


Update ProfileProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PROPERTYADDRESS)+1,LEN(PROPERTYADDRESS))


SELECT OwnerAddress
     , PARSENAME(REPLACE(OWNERADDRESS,',','.'),3) AS  OwnerSplitAddress
	 , PARSENAME(REPLACE(OWNERADDRESS,',','.'),2) AS  OwnerSplitCity
	 , PARSENAME(REPLACE(OWNERADDRESS,',','.'),1) AS  OwnerSplitState 
FROM ProfileProject..NashvilleHousing


ALTER TABLE profileproject..nashvillehousing
ADD  OwnerSplitAddress Nvarchar(255),
     OwnerSplitCity  Nvarchar(255),
	 OwnerSplitState  Nvarchar(5);

Update ProfileProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)


Update ProfileProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OWNERADDRESS,',','.'),2)

Update ProfileProject..NashvilleHousing
Set  OwnerSplitState  = PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SOLDASVACANT)
FROM ProfileProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SOLDASVACANT
     , CASE
	       WHEN SOLDASVACANT = 'Y' THEN 'Yes'
		   WHEN SOLDASVACANT = 'N' THEN 'No'
		   ELSE SOLDASVACANT
		END AS MODSOLDASVACANT
FROM ProfileProject..NashvilleHousing


UPDATE ProfileProject..NashvilleHousing
SET SOLDASVACANT = CASE
	       WHEN SOLDASVACANT = 'Y' THEN 'Yes'
		   WHEN SOLDASVACANT = 'N' THEN 'No'
		   ELSE SOLDASVACANT
		END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH EVERTYHING AS
(
SELECT *
     , ROW_NUMBER () OVER(PARTITION BY PARCELID, PROPERTYADDRESS,SALEPRICE,SALEDATE,LEGALREFERENCE ORDER BY UNIQUEID) AS ROWNUM
FROM ProfileProject..NashvilleHousing
)

SELECT *
FROM EVERTYHING
WHERE ROWNUM >1


-- I WONT, BUT IT WOULD BE A DELETE FROM STATEMENT HERE TO REMOVE DUPLICATE ROWS

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE ProfileProject..NashvilleHousing
DROP COLUMN OWNERADDRESS,PROPERTYADDRESS,SALEDATE
