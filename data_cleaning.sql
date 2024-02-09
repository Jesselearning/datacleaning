-- Cleaning Data in SQL Queries

select *
from NashvilleHousingData

-- Standardize Sales date
select SaleDate, CONVERT(date, SaleDate) standardDate
from NashvilleHousingData

alter TABLE NashvilleHousingData
ADD SaleDateConverted Date;

update NashvilleHousingData
set SaleDateConverted=CONVERT(date, SaleDate)

-- Populate Property Address Data

select *
from NashvilleHousingData
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b
    ON a.ParcelID=b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


UPDATE a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b
    ON a.ParcelID=b.ParcelID
    and a.UniqueID <> b.UniqueID


-- Breaking out Address into Individual Columns (Address, City, States)
SELECT PropertyAddress
from NashvilleHousingData

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousingData

alter TABLE NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255);

update NashvilleHousingData
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter TABLE NashvilleHousingData
ADD PropertySplitCity NVARCHAR(255);

update NashvilleHousingData
set PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
from NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousingData


alter TABLE NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255);

update NashvilleHousingData
set OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter TABLE NashvilleHousingData
ADD OwnerSplitCity NVARCHAR(255);

update NashvilleHousingData
set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter TABLE NashvilleHousingData
ADD OwnerSplitState NVARCHAR(255);

update NashvilleHousingData
set OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * from NashvilleHousingData

-- Change Y and N to Yes and No in SoldAsVacant
SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousingData
GROUP by SoldAsVacant

select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
    when SoldAsVacant='N' then 'No'
    else SoldAsVacant
    end
from NashvilleHousingData


update NashvilleHousingData
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
    when SoldAsVacant='N' then 'No'
    else SoldAsVacant
    end

-- Remove Duplicates
with row_num_cte as (
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION by ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate, 
    LegalReference
    order by UniqueID
    ) row_num
from NashvilleHousingData
-- order by ParcelID
)
SELECT * from 
row_num_cte
where row_num > 1
-- order by PropertyAddress

-- Delete Unused Columns
select * from NashvilleHousingData

alter table NashvilleHousingData 
drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress


alter table NashvilleHousingData 
drop COLUMN SaleDate
