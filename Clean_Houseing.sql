-- Cleaning data in SQL Queries

Select *
From dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, CONVERT(date,SaleDate)
From dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------
-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress NVarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter Table NashvilleHousing
Add PropertySplitCity NVarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From dbo.NashvilleHousing



Select OwnerAddress
From dbo.NashvilleHousing

Select
PARSENAME(replace(Owneraddress, ',', '.'), 3)
,PARSENAME(replace(Owneraddress, ',', '.'), 2)
,PARSENAME(replace(Owneraddress, ',', '.'), 1)
From dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress NVarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(Owneraddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(Owneraddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState NVarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(Owneraddress, ',', '.'), 1)




--------------------------------------------------------------------------------------------------------------------
-- Change Y And N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2



Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from dbo.NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End





--------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition by  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) Row_Num

From dbo.NashvilleHousing
--Order by ParcelID
)
--Delete
Select *
From RowNumCTE
Where Row_Num > 1
--Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From dbo.NashvilleHousing

ALTER TABLE Dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Dbo.NashvilleHousing
drop column SaleDate