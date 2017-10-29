package com.example.circletest.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * Created by suyamayutaro on 2017/10/29.
 */
@Repository
public class HogeRepository {

	@Autowired
	private JdbcTemplate jdbcTemplate;

	public void create()
	{
		jdbcTemplate.update(
				"INSERT INTO FUGA(NAME) VALUES (?)"
				, "ODEN"
		);
	}
}
