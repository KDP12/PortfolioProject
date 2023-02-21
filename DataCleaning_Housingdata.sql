--NASHVILLE HOUSING DATASET

Select *
from portfolioproject..NashvilleHousing

------------------------------------------------------------------------

--Standardize Sale Date

Select SaleDateConverted, Convert(Date,Saledate)
from portfolioproject..NashvilleHousing

Update NashvilleHousing
SET Saledate = Convert(Date,Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)


---------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from portfolioproject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NashvilleHousing a
Join portfolioproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress  is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NashvilleHousing a
Join portfolioproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


----------------------------------------------------------------------------

--Breaking out Address into Individual columns(Address,City,State)


Select *
from portfolioproject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS  Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS  Address
--SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS  Address
from portfolioproject..NashvilleHousing

--Property Address

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)
Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 
 
--Property City

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)
Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Owner Address,City,State

Select OwnerAddress
from portfolioproject..NashvilleHousing

SELECT 
Parsename(REPLACE(OwnerAddress,',','.'),3),
Parsename(REPLACE(OwnerAddress,',','.'),2),
Parsename(REPLACE(OwnerAddress,',','.'),1)
from portfolioproject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitaddress Nvarchar(255)
Update NashvilleHousing
set OwnerSplitaddress = Parsename(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerplitCity Nvarchar(255)
Update NashvilleHousing
set OwnerplitCity = Parsename(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)
Update NashvilleHousing
set OwnerSplitState = Parsename(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Count
from portfolioproject..NashvilleHousing
group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from portfolioproject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

------------------------------------------------------------------------------

--Remove Duplicates

WITH rownumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by 
				    UniqueID
					) ROW_NUM
from portfolioproject..NashvilleHousing
--Order By ParcelID
)
select * 
from RownumCTE
Where row_num > 1 

-------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
from portfolioproject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN OwnerAddress, Taxdistrict, PropertyAddress

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN Saledate
