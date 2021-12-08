-- Cleaning data in SQL

select *
from PortfolioProject..nashville_housing

-- Standardize Date Format

select saledateconverted, CONVERT(date, SaleDate)
from PortfolioProject..nashville_housing

--update nashville_housing
--SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE nashville_housing
Add SaleDateConverted Date;

Update nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address

Select *
From PortfolioProject..nashville_housing
--WHERE PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Indivual Colums (Address, City, State)

Select PropertyAddress
From PortfolioProject..nashville_housing
--WHERE PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

Select*
From PortfolioProject..nashville_housing
-- may not need use statement, but if you get an error about missing dataset USE statement will help solve the issue
USE PortfolioProject
ALTER TABLE nashville_housing
Add PropertySplitAddress Nvarchar(255);

Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

USE PortfolioProject
ALTER TABLE nashville_housing
Add PropertySplitCity NVARCHAR(255);

Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PortfolioProject..nashville_housing


Select OwnerAddress
From PortfolioProject..nashville_housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..nashville_housing



USE PortfolioProject
ALTER TABLE nashville_housing
Add OwnerSplitAddress Nvarchar(255);

Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

USE PortfolioProject
ALTER TABLE nashville_housing
Add OwnerSplitCity NVARCHAR(255);

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

USE PortfolioProject
ALTER TABLE nashville_housing
Add OwnerSplitState NVARCHAR(255);

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
from PortfolioProject..nashville_housing




-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..nashville_housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..nashville_housing

USE PortfolioProject
Update nashville_housing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




	   -- Remove Duplicates

WITH RownumCTE AS(
Select *, 
		ROW_NUMBER()Over(
		PARTITION BY ParcelID, 
				  PropertyAddress,
				  SaleDate,
				  SaleDate,
				  LegalReference
				  Order By
					UniqueID
					) Row_num

From PortfolioProject..nashville_housing
)

--Used to delete duplicates
--Delete
--From RownumCTE
--Where row_num > 1

Select*
From RownumCTE
Where row_num > 1
Order By PropertyAddress

--Delete Unused Colums

Select*
From PortfolioProject..nashville_housing


ALter Table PortfolioProject..nashville_housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate