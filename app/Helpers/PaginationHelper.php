<?php

declare(strict_types=1);

namespace Vanier\Api\Helpers;

/**
 * Provides an offset-based pagination service. 
 *
 * @author Sleiman Rabah
 */
class PaginationHelper
{

    /**
     * The index of the current page.
     * @var int
     */
    private $current_page;

    /**
     * Holds the number of records per page.
     * @var int
     */
    private $records_per_page;

    /**
     * The total number of records contained in the fetched result set 
     * to be paginated.
     * @var int
     */
    private $total_records;

    /**
     * The total number of pages there will be in the result set.
     * @var int 
     */
    private $total_pages;

    /**
     * Configures a Paginator instance with the provided parameters.
     *  
     * @param int $page_number  the page number to be selected.
     * @param int $page_size   the number of records to fit in one page.
     * @param int $total_count the total number of records in a result set to be paginated.
     */
    public function __construct(int $page_number = 1, int $page_size = 10, int $total_count = 0)
    {
        $this->current_page = $page_number;
        $this->records_per_page = $page_size;
        $this->total_records = $total_count;
        $this->total_pages = $this->getTotalPages();
        // Set the current page to 1 if the current page is negative 
        // or the current page is greater than the total number of pages.
        if ($this->current_page < 1 || $this->current_page > $this->total_pages) {
            $this->current_page = 1;
        }
    }

    /**
     * Gets the offset that identifies the starting point to return rows from a result set.        
     * An offset is the number of records to skip before returning 
     * the result set to the client.
     * @return int 
     */
    public function getOffset(): int
    {
        // 
        return ($this->current_page - 1) * $this->records_per_page;
    }

    /**
     * Returns the total number of records contained in the result set.
     * @return int
     */
    public function getTotalRecords(): int
    {
        return $this->total_records;
    }

    /**
     * Computes how many pages there will be in the result set. 
     * @return int the computed number of pages.
     */
    public function getTotalPages(): int
    {
        if (!empty($this->total_records)) {
            // Calculate the total number of pages.
            return (int) ceil($this->total_records / $this->records_per_page);
        }
        return 0;
    }

    /**
     * Gets the computed pagination meta data. It includes the total of pages,
     *  current page, number of records per page, and last page. 
     * 
     * @return array containing information about the produced pages.
     */
    public function getPaginationInfo(): array
    {
        return array(
            "count" => $this->total_records,
            "offset" => $this->getOffset(),
            "page" => $this->current_page,
            "page_size" => $this->records_per_page,
            "last_page" => $this->total_pages,
        );
    }
}
