package com.example.circletest;

import com.example.circletest.repository.HogeRepository;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;

@RunWith(SpringRunner.class)
@SpringBootTest
public class CircletestApplicationTests {

	@Autowired
	HogeRepository hogeRepository;


	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Test
	public void contextLoads() {
		hogeRepository.create();

		List<Map<String, Object>> list = jdbcTemplate.queryForList("SELECT name FROM fuga ORDER BY ID LIMIT 1");
		for (Map<String, Object> map : list) {
			System.out.println(map.get("name").toString());

			assertEquals("ODEN", map.get("name").toString());
		}
	}

}
