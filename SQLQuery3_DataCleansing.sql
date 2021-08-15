-- cleaning data in SQL queries

select *
from PortfolioProject.dbo.NashvilleHousing


-- Standarized date format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate property date address

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID  --has same parcel id but some addresses are missing so point here is use the same address as reference

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

--check if worked, execute 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 



--Breaking out Address into Individual columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID  

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

--to remove comma (,)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress) --gives count at  what position is comma
from PortfolioProject.dbo.NashvilleHousing

--to remove comma (-1)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
from PortfolioProject.dbo.NashvilleHousing

--creating a seperate column for state using substring (using parse is more easy, scroll down to find)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address  --+1 removes comma
from PortfolioProject.dbo.NashvilleHousing

--adding changed address to main table
ALTER table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- to view change, newly added columns are in last
Select *
From PortfolioProject.dbo.NashvilleHousing


--to delete any column 
--Alter table NashvilleHousing Drop column PropertyASplitCity

Select *
From PortfolioProject.dbo.NashvilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing



Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)  --parsename seperates from backwards
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
From PortfolioProject.dbo.NashvilleHousing

--making it work from front, change the sequence number
Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



--adding changed owneraddress to main table
ALTER table NashvilleHousing
Add OwnerStreetName Nvarchar(255);

Update NashvilleHousing
SET OwnerStreetName = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)

ALTER table NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)

ALTER table NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)

--to view the change
select * 
From PortfolioProject.dbo.NashvilleHousing




--Change values in SoldAsVacant column (Y,N,Yes and No) and make it uniform based highest distinct value count 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
From PortfolioProject.dbo.NashvilleHousing


--update change to main table
update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
From PortfolioProject.dbo.NashvilleHousing




--remove Dulicates

With RowNumCTE AS (
select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
 
from PortfolioProject.dbo.NashvilleHousing
)
select *
From RowNumCTE
where row_num > 1  --selects rows that are duplicates i.e. row_num >1 ; repeated
order by PropertyAddress 



With RowNumCTE AS (
select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
 
from PortfolioProject.dbo.NashvilleHousing
)
delete        --deleting duplicates
From RowNumCTE
where row_num > 1 


-- verifying
select *
from PortfolioProject.dbo.NashvilleHousing


-- deleting unused columns and removing duplicates are not good practice as you might loose valuable data, 
--make sure before you do that. 
-- Delete unused columns

select *
From PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing 
Drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing 
Drop column SaleDate